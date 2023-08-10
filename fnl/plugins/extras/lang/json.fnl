[{1 :nvim-treesitter/nvim-treesitter
  :opts (fn [_ opts]
          (when (= (type opts.ensure_installed) :table)
            (vim.list_extend opts.ensure_installed [:json :json5 :jsonc])))}
 {1 :b0o/SchemaStore.nvim :lazy true :version false}
 {1 :neovim/nvim-lspconfig
  :opts {:servers {:jsonls {:on_new_config (fn [new-config]
                                             (set new-config.settings.json.schemas
                                                  (or new-config.settings.json.schemas
                                                      {}))
                                             (vim.list_extend new-config.settings.json.schemas
                                                              ((. (require :schemastore)
                                                                  :json :schemas))))
                            :settings {:json {:format {:enable true}
                                              :validate {:enable true}}}}}}}]

