[{1 :Hoffs/omnisharp-extended-lsp.nvim :lazy true}
 {1 :nvim-treesitter/nvim-treesitter
  :opts (fn [_ opts]
          (when (= (type opts.ensure_installed) :table)
            (vim.list_extend opts.ensure_installed [:c_sharp])))}
 {1 :nvimtools/none-ls.nvim
  :optional true
  :opts (fn [_ opts]
          (local nls (require :null-ls))
          (set opts.sources (or opts.sources {}))
          (table.insert opts.sources nls.builtins.formatting.csharpier))}
 {1 :stevearc/conform.nvim
  :optional true
  :opts {:formatters {:csharpier {:args [:--write-stdout]
                                  :command :dotnet-csharpier}}
         :formatters_by_ft {:cs [:csharpier]}}}
 {1 :williamboman/mason.nvim
  :opts (fn [_ opts]
          (set opts.ensure_installed (or opts.ensure_installed {}))
          (table.insert opts.ensure_installed :csharpier))}
 {1 :neovim/nvim-lspconfig
  :opts {:servers {:omnisharp {:enable_import_completion true
                               :enable_roslyn_analyzers true
                               :handlers {:textDocument/definition (fn [...]
                                                                     ((. (require :omnisharp_extended)
                                                                         :handler) ...))}
                               :keys [{1 :gd
                                       2 (fn []
                                           ((. (require :omnisharp_extended)
                                               :telescope_lsp_definitions)))
                                       :desc "Goto Definition"}]
                               :organize_imports_on_format true}}}}]

