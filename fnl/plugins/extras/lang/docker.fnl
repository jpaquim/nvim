[{1 :nvim-treesitter/nvim-treesitter
  :opts (fn [_ opts]
          (when (= (type opts.ensure_installed) :table)
            (vim.list_extend opts.ensure_installed [:dockerfile])))}
 {1 :mason.nvim
  :opts (fn [_ opts]
          (set opts.ensure_installed (or opts.ensure_installed {}))
          (vim.list_extend opts.ensure_installed [:hadolint]))}
 {1 :nvimtools/none-ls.nvim
  :optional true
  :opts (fn [_ opts]
          (local nls (require :null-ls))
          (set opts.sources
               (vim.list_extend (or opts.sources {})
                                [nls.builtins.diagnostics.hadolint])))}
 {1 :mfussenegger/nvim-lint
  :optional true
  :opts {:linters_by_ft {:dockerfile [:hadolint]}}}
 {1 :neovim/nvim-lspconfig
  :opts {:servers {:docker_compose_language_service {} :dockerls {}}}}]

