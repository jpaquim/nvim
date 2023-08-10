[{1 :folke/which-key.nvim
  :optional true
  :opts {:defaults {:<localLeader>l {:name :+vimtex}}}}
 {1 :nvim-treesitter/nvim-treesitter
  :opts (fn [_ opts]
          (when (= (type opts.ensure_installed) :table)
            (vim.list_extend opts.ensure_installed [:bibtex :latex]))
          (if (= (type opts.highlight.disable) :table)
              (vim.list_extend opts.highlight.disable [:latex])
              (set opts.highlight.disable [:latex])))}
 {1 :lervag/vimtex
  :config (fn []
            (vim.api.nvim_create_autocmd [:FileType]
                                         {:callback (fn []
                                                      (set vim.wo.conceallevel
                                                           2))
                                          :group (vim.api.nvim_create_augroup :lazyvim_vimtex_conceal
                                                                              {:clear true})
                                          :pattern [:bib :tex]})
            (set vim.g.vimtex_mappings_disable {:n [:K]})
            (set vim.g.vimtex_quickfix_method
                 (or (and (= (vim.fn.executable :pplatex) 1) :pplatex)
                     :latexlog)))
  :lazy false}
 {1 :neovim/nvim-lspconfig
  :optional true
  :opts {:servers {:texlab {:keys [{1 :<Leader>K
                                    2 "<plug>(vimtex-doc-package)"
                                    :desc "Vimtex Docs"
                                    :silent true}]}}}}]

