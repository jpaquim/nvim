[{1 :neovim/nvim-lspconfig
  :opts {:servers {:tailwindcss {:filetypes_exclude [:markdown]
                                 :filetypes_include {}}}
         :setup {:tailwindcss (fn [_ opts]
                                (local tw
                                       (require :lspconfig.server_configurations.tailwindcss))
                                (set opts.filetypes (or opts.filetypes {}))
                                (vim.list_extend opts.filetypes
                                                 tw.default_config.filetypes)
                                (set opts.filetypes
                                     (vim.tbl_filter (fn [ft]
                                                       (not (vim.tbl_contains (or opts.filetypes_exclude
                                                                                  {})
                                                                              ft)))
                                                     opts.filetypes))
                                (vim.list_extend opts.filetypes
                                                 (or opts.filetypes_include {})))}}}
 {1 :hrsh7th/nvim-cmp
  :dependencies [{1 :roobert/tailwindcss-colorizer-cmp.nvim :config true}]
  :opts (fn [_ opts]
          (local format-kinds opts.formatting.format)
          (set opts.formatting.format
               (fn [entry item]
                 (format-kinds entry item)
                 ((. (require :tailwindcss-colorizer-cmp) :formatter) entry
                                                                      item))))}]

