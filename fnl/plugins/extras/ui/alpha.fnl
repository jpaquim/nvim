[{1 :glepnir/dashboard-nvim :enabled false}
 {1 :echasnovski/mini.starter :enabled false}
 {1 :goolord/alpha-nvim
  :config (fn [_ dashboard]
            (when (= vim.o.filetype :lazy)
              (vim.cmd.close)
              (vim.api.nvim_create_autocmd :User
                                           {:callback (fn []
                                                        ((. (require :lazy)
                                                            :show)))
                                            :once true
                                            :pattern :AlphaReady}))
            ((. (require :alpha) :setup) dashboard.opts)
            (vim.api.nvim_create_autocmd :User
                                         {:callback (fn []
                                                      (local stats
                                                             ((. (require :lazy)
                                                                 :stats)))
                                                      (local ms
                                                             (/ (math.floor (+ (* stats.startuptime
                                                                                  100)
                                                                               0.5))
                                                                100))
                                                      (set dashboard.section.footer.val
                                                           (.. "⚡ Neovim loaded "
                                                               stats.loaded "/"
                                                               stats.count
                                                               " plugins in " ms
                                                               :ms))
                                                      (pcall vim.cmd.AlphaRedraw))
                                          :once true
                                          :pattern :LazyVimStarted}))
  :enabled true
  :event :VimEnter
  :init false
  :opts (fn []
          (local dashboard (require :alpha.themes.dashboard))
          (local logo "           ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
           ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z    
           ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z       
           ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z         
           ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
           ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
      ")
          (set dashboard.section.header.val (vim.split logo "\n"))
          (set dashboard.section.buttons.val
               [(dashboard.button :f (.. " " " Find file")
                                  "<cmd> Telescope find_files <cr>")
                (dashboard.button :n (.. " " " New file")
                                  "<cmd> ene <BAR> startinsert <cr>")
                (dashboard.button :r (.. " " " Recent files")
                                  "<cmd> Telescope oldfiles <cr>")
                (dashboard.button :g (.. " " " Find text")
                                  "<cmd> Telescope live_grep <cr>")
                (dashboard.button :c (.. " " " Config")
                                  "<cmd> e $MYVIMRC <cr>")
                (dashboard.button :s (.. " " " Restore Session")
                                  "<cmd> lua require(\"persistence\").load() <cr>")
                (dashboard.button :e (.. " " " Lazy Extras")
                                  "<cmd> LazyExtras <cr>")
                (dashboard.button :l (.. "󰒲 " " Lazy") "<cmd> Lazy <cr>")
                (dashboard.button :q (.. " " " Quit") "<cmd> qa <cr>")])
          (each [_ button (ipairs dashboard.section.buttons.val)]
            (set button.opts.hl :AlphaButtons)
            (set button.opts.hl_shortcut :AlphaShortcut))
          (set dashboard.section.header.opts.hl :AlphaHeader)
          (set dashboard.section.buttons.opts.hl :AlphaButtons)
          (set dashboard.section.footer.opts.hl :AlphaFooter)
          (tset (. dashboard.opts.layout 1) :val 8)
          dashboard)}]

