(vim.api.nvim_create_autocmd :FileType
                             {:command "setlocal commentstring=#\\ %s"
                              :desc "terraform/hcl commentstring configuration"
                              :pattern [:hcl :terraform]})

[{1 :nvim-treesitter/nvim-treesitter
  :opts (fn [_ opts]
          (when (= (type opts.ensure_installed) :table)
            (vim.list_extend opts.ensure_installed [:terraform :hcl])))}
 {1 :neovim/nvim-lspconfig :opts {:servers {:terraformls {}}}}
 {1 :nvimtools/none-ls.nvim
  :optional true
  :opts (fn [_ opts]
          (local null-ls (require :null-ls))
          (set opts.sources
               (vim.list_extend (or opts.sources {})
                                [null-ls.builtins.formatting.terraform_fmt
                                 null-ls.builtins.diagnostics.terraform_validate])))}
 {1 :mfussenegger/nvim-lint
  :optional true
  :opts {:linters_by_ft {:terraform [:terraform_validate]
                         :tf [:terraform_validate]}}}
 {1 :stevearc/conform.nvim
  :optional true
  :opts {:formatters_by_ft {:terraform [:terraform_fmt]
                            :terraform-vars [:terraform_fmt]
                            :tf [:terraform_fmt]}}}]

