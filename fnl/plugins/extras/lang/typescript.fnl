[{1 :nvim-treesitter/nvim-treesitter
  :opts (fn [_ opts]
          (when (= (type opts.ensure_installed) :table)
            (vim.list_extend opts.ensure_installed [:typescript :tsx])))}
 {1 :neovim/nvim-lspconfig
  :opts {:servers {:tsserver {:keys [{1 :<leader>co
                                      2 (fn []
                                          (vim.lsp.buf.code_action {:apply true
                                                                    :context {:diagnostics {}
                                                                              :only [:source.organizeImports.ts]}}))
                                      :desc "Organize Imports"}]
                              :settings {:completions {:completeFunctionCalls true}
                                         :javascript {:format {:convertTabsToSpaces vim.o.expandtab
                                                               :indentSize vim.o.shiftwidth
                                                               :tabSize vim.o.tabstop}}
                                         :typescript {:format {:convertTabsToSpaces vim.o.expandtab
                                                               :indentSize vim.o.shiftwidth
                                                               :tabSize vim.o.tabstop}}}}}}}
 {1 :mfussenegger/nvim-dap
  :dependencies [{1 :williamboman/mason.nvim
                  :opts (fn [_ opts]
                          (set opts.ensure_installed
                               (or opts.ensure_installed {}))
                          (table.insert opts.ensure_installed :js-debug-adapter))}]
  :optional true
  :opts (fn []
          (local dap (require :dap))
          (when (not (. dap.adapters :pwa-node))
            (tset (. (require :dap) :adapters) :pwa-node
                  {:executable {:args [(.. (: ((. (require :mason-registry)
                                                  :get_package) :js-debug-adapter)
                                              :get_install_path)
                                           :/js-debug/src/dapDebugServer.js)
                                       "${port}"]
                                :command :node}
                   :host :localhost
                   :port "${port}"
                   :type :server}))
          (each [_ language (ipairs [:typescript
                                     :javascript
                                     :typescriptreact
                                     :javascriptreact])]
            (when (not (. dap.configurations language))
              (tset dap.configurations language
                    [{:cwd "${workspaceFolder}"
                      :name "Launch file"
                      :program "${file}"
                      :request :launch
                      :type :pwa-node}
                     {:cwd "${workspaceFolder}"
                      :name :Attach
                      :processId (. (require :dap.utils) :pick_process)
                      :request :attach
                      :type :pwa-node}]))))}]

