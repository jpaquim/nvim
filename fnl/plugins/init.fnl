(when (= (vim.fn.has :nvim-0.9.0) 0)
  (vim.api.nvim_echo [["LazyVim requires Neovim >= 0.9.0\n" :ErrorMsg]
                      ["Press any key to exit" :MoreMsg]]
                     true {})
  (vim.fn.getchar)
  (vim.cmd :quit)
  (let [___antifnl_rtn_1___ {}] (lua "return ___antifnl_rtn_1___")))

((. (require :config) :init))

[{1 :folke/lazy.nvim :version "*"}
 {1 :LazyVim/LazyVim
  :cond true
  :config true
  :lazy false
  :priority 10000
  :version "*"}]

