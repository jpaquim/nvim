[{1 :nvim-treesitter/nvim-treesitter
  :opts (fn [_ opts]
          (vim.list_extend opts.ensure_installed [:go :gomod :gowork :gosum]))}
 {1 :neovim/nvim-lspconfig
  :opts {:servers {:gopls {:keys [{1 :<leader>td
                                   2 "<cmd>lua require('dap-go').debug_test()<CR>"
                                   :desc "Debug Nearest (Go)"}]
                           :settings {:gopls {:analyses {:fieldalignment true
                                                         :nilness true
                                                         :unusedparams true
                                                         :unusedwrite true
                                                         :useany true}
                                              :codelenses {:gc_details false
                                                           :generate true
                                                           :regenerate_cgo true
                                                           :run_govulncheck true
                                                           :test true
                                                           :tidy true
                                                           :upgrade_dependency true
                                                           :vendor true}
                                              :completeUnimported true
                                              :directoryFilters [:-.git
                                                                 :-.vscode
                                                                 :-.idea
                                                                 :-.vscode-test
                                                                 :-node_modules]
                                              :gofumpt true
                                              :hints {:assignVariableTypes true
                                                      :compositeLiteralFields true
                                                      :compositeLiteralTypes true
                                                      :constantValues true
                                                      :functionTypeParameters true
                                                      :parameterNames true
                                                      :rangeVariableTypes true}
                                              :semanticTokens true
                                              :staticcheck true
                                              :usePlaceholders true}}}}
         :setup {:gopls (fn [_ opts]
                          ((. (require :util) :lsp :on_attach) (fn [client _]
                                                                 (when (= client.name
                                                                          :gopls)
                                                                   (when (not client.server_capabilities.semanticTokensProvider)
                                                                     (local semantic
                                                                            client.config.capabilities.textDocument.semanticTokens)
                                                                     (set client.server_capabilities.semanticTokensProvider
                                                                          {:full true
                                                                           :legend {:tokenModifiers semantic.tokenModifiers
                                                                                    :tokenTypes semantic.tokenTypes}
                                                                           :range true}))))))}}}
 {1 :nvimtools/none-ls.nvim
  :optional true
  :opts (fn [_ opts]
          (local nls (require :null-ls))
          (set opts.sources
               (vim.list_extend (or opts.sources {})
                                [nls.builtins.code_actions.gomodifytags
                                 nls.builtins.code_actions.impl
                                 nls.builtins.formatting.goimports])))}
 {1 :stevearc/conform.nvim
  :optional true
  :opts {:formatters_by_ft {:go [:goimports]}}}
 {1 :mfussenegger/nvim-dap
  :dependencies [{1 :mason.nvim
                  :opts (fn [_ opts]
                          (set opts.ensure_installed
                               (or opts.ensure_installed {}))
                          (vim.list_extend opts.ensure_installed
                                           [:gomodifytags
                                            :impl
                                            :goimports
                                            :delve]))}
                 {1 :leoluz/nvim-dap-go :config true}]
  :optional true}
 {1 :nvim-neotest/neotest
  :dependencies [:nvim-neotest/neotest-go]
  :optional true
  :opts {:adapters {:neotest-go {}}}}]

