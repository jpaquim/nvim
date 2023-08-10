(local M {})

(fn M.get_clients [...]
  (let [___fn___ (or vim.lsp.get_clients vim.lsp.get_active_clients)]
    (___fn___ ...)))

(fn M.on_attach [on-attach]
  (vim.api.nvim_create_autocmd :LspAttach
                               {:callback (fn [args] (local buffer args.buf)
                                            (local client
                                                   (vim.lsp.get_client_by_id args.data.client_id))
                                            (on-attach client buffer))}))

(fn M.on_rename [from to]
  (let [clients (M.get_clients)]
    (each [_ client (ipairs clients)]
      (when (client.supports_method :workspace/willRenameFiles)
        (local resp (client.request_sync :workspace/willRenameFiles
                                         {:files [{:newUri (vim.uri_from_fname to)
                                                   :oldUri (vim.uri_from_fname from)}]}
                                         1000 0))
        (when (and resp (not= resp.result nil))
          (vim.lsp.util.apply_workspace_edit resp.result client.offset_encoding))))))

(fn M.get_config [server]
  (let [configs (require :lspconfig.configs)] (rawget configs server)))

(fn M.disable [server cond]
  (let [util (require :lspconfig.util)
        def (M.get_config server)]
    (set def.document_config.on_new_config
         (util.add_hook_before def.document_config.on_new_config
                               (fn [config root-dir]
                                 (when (cond root-dir config)
                                   (set config.enabled false)))))))

(fn M.filter [name] (fn [client] (= client.name name)))

(fn M.formatter [opts]
  (set-forcibly! opts (or opts {}))
  (var filter opts.filter)
  (set filter (or (and (= (type filter) :string) (M.filter filter)) filter))
  (local ret
         {:format (fn [buf] (M.format {:bufnr buf : filter}))
          :name :LSP
          :primary true
          :priority 1
          :sources (fn [buf]
                     (local clients (M.get_clients {:bufnr buf}))
                     (local ret
                            (vim.tbl_filter (fn [client]
                                              (and (or (not filter)
                                                       (filter client))
                                                   (or (client.supports_method :textDocument/formatting)
                                                       (client.supports_method :textDocument/rangeFormatting))))
                                            clients))
                     (vim.tbl_map (fn [client] client.name) ret))})
  (vim.tbl_deep_extend :force ret opts))

(fn M.format [opts]
  (vim.lsp.buf.format (vim.tbl_deep_extend :force (or opts {})
                                           (or (. ((. (require :util) :opts) :nvim-lspconfig)
                                                  :format)
                                               {}))))

M

