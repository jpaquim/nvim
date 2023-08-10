[{1 :nvim-treesitter/nvim-treesitter
  :opts (fn [_ opts]
          (when (= (type opts.ensure_installed) :table)
            (vim.list_extend opts.ensure_installed [:yaml])))}
 {1 :b0o/SchemaStore.nvim :lazy true :version false}
 {1 :neovim/nvim-lspconfig
  :opts {:servers {:yamlls {:capabilities {:textDocument {:foldingRange {:dynamicRegistration false
                                                                         :lineFoldingOnly true}}}
                            :on_new_config (fn [new-config]
                                             (set new-config.settings.yaml.schemas
                                                  (vim.tbl_deep_extend :force
                                                                       (or new-config.settings.yaml.schemas
                                                                           {})
                                                                       ((. (require :schemastore)
                                                                           :yaml
                                                                           :schemas)))))
                            :settings {:redhat {:telemetry {:enabled false}}
                                       :yaml {:format {:enable true}
                                              :keyOrdering false
                                              :schemaStore {:enable false
                                                            :url ""}
                                              :validate true}}}}
         :setup {:yamlls (fn []
                           (when (= (vim.fn.has :nvim-0.10) 0)
                             ((. (require :util) :lsp :on_attach) (fn [client
                                                                       _]
                                                                    (when (= client.name
                                                                             :yamlls)
                                                                      (set client.server_capabilities.documentFormattingProvider
                                                                           true))))))}}}]

