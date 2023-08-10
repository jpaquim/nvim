(when (not vim.g.vscode)
  (let [___antifnl_rtn_1___ {}] (lua "return ___antifnl_rtn_1___")))

(local enabled [:flit.nvim
                :lazy.nvim
                :leap.nvim
                :mini.ai
                :mini.comment
                :mini.pairs
                :mini.surround
                :nvim-treesitter
                :nvim-treesitter-textobjects
                :nvim-ts-context-commentstring
                :vim-repeat
                :LazyVim])

(local Config (require :lazy.core.config))

(set Config.options.checker.enabled false)

(set Config.options.change_detection.enabled false)

(set Config.options.defaults.cond
     (fn [plugin] (or (vim.tbl_contains enabled plugin.name) plugin.vscode)))

(vim.api.nvim_create_autocmd :User
                             {:callback (fn []
                                          (vim.keymap.set :n :<leader><space>
                                                          :<cmd>Find<cr>)
                                          (vim.keymap.set :n :<leader>/
                                                          "<cmd>call VSCodeNotify('workbench.action.findInFiles')<cr>")
                                          (vim.keymap.set :n :<leader>ss
                                                          "<cmd>call VSCodeNotify('workbench.action.gotoSymbol')<cr>"))
                              :pattern :LazyVimKeymaps})

[{1 :LazyVim/LazyVim
  :config (fn [_ opts]
            (set-forcibly! opts (or opts {}))
            (set opts.colorscheme (fn []))
            ((. (require :lazyvim) :setup) opts))}
 {1 :nvim-treesitter/nvim-treesitter :opts {:highlight {:enable false}}}]

