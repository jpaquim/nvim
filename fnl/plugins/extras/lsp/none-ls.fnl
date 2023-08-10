(local Util (require :util))

[{1 :nvimtools/none-ls.nvim
  :dependencies [:mason.nvim]
  :event :LazyFile
  :init (fn []
          (Util.on_very_lazy (fn []
                               ((. (require :util) :format :register) {:format (fn [buf]
                                                                                 (Util.lsp.format {:bufnr buf
                                                                                                   :filter (fn [client]
                                                                                                             (= client.name
                                                                                                                :null-ls))}))
                                                                       :name :none-ls.nvim
                                                                       :primary true
                                                                       :priority 200
                                                                       :sources (fn [buf]
                                                                                  (local ret
                                                                                         (or ((. (require :null-ls.sources)
                                                                                                 :get_available) (. vim.bo
                                                                                                                                                                                                                                                buf
                                                                                                                                                                                                                                                :filetype)
                                                                                                                                                                                                                                             :NULL_LS_FORMATTING)
                                                                                             {}))
                                                                                  (vim.tbl_map (fn [source]
                                                                                                 source.name)
                                                                                               ret))}))))
  :opts (fn [_ opts]
          (local nls (require :null-ls))
          (set opts.root_dir
               (or opts.root_dir
                   ((. (require :null-ls.utils) :root_pattern) :.null-ls-root
                                                               :.neoconf.json
                                                               :Makefile :.git)))
          (set opts.sources
               (vim.list_extend (or opts.sources {})
                                [nls.builtins.formatting.fish_indent
                                 nls.builtins.diagnostics.fish
                                 nls.builtins.formatting.stylua
                                 nls.builtins.formatting.shfmt])))}]

