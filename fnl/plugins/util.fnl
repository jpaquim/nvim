[{1 :dstein64/vim-startuptime
  :cmd :StartupTime
  :config (fn [] (set vim.g.startuptime_tries 10))}
 {1 :folke/persistence.nvim
  :event :BufReadPre
  :keys [{1 :<leader>qs
          2 (fn []
              ((. (require :persistence) :load)))
          :desc "Restore Session"}
         {1 :<leader>ql
          2 (fn []
              ((. (require :persistence) :load) {:last true}))
          :desc "Restore Last Session"}
         {1 :<leader>qd
          2 (fn []
              ((. (require :persistence) :stop)))
          :desc "Don't Save Current Session"}]
  :opts {:options [:buffers :curdir :tabpages :winsize :help :globals :skiprtp]}}
 {1 :nvim-lua/plenary.nvim :lazy true}]

