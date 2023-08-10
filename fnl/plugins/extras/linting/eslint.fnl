[{1 :neovim/nvim-lspconfig
  :opts {:servers {:eslint {:settings {:workingDirectory {:mode :auto}}}}
         :setup {:eslint (fn []
                           (fn get-client [buf]
                             (. ((. (require :util) :lsp :get_clients) {:bufnr buf
                                                                        :name :eslint})
                                1))

                           (local formatter
                                  ((. (require :util) :lsp :formatter) {:filter :eslint
                                                                        :name "eslint: lsp"
                                                                        :primary false
                                                                        :priority 200}))
                           (when (not (pcall require :vim.lsp._dynamic))
                             (set formatter.name "eslint: EslintFixAll")
                             (set formatter.sources
                                  (fn [buf]
                                    (local client (get-client buf))
                                    (or (and client [:eslint]) {})))
                             (set formatter.format
                                  (fn [buf]
                                    (local client (get-client buf))
                                    (when client
                                      (local diag
                                             (vim.diagnostic.get buf
                                                                 {:namespace (vim.lsp.diagnostic.get_namespace client.id)}))
                                      (when (> (length diag) 0)
                                        (vim.cmd :EslintFixAll))))))
                           ((. (require :util) :format :register) formatter))}}}]

