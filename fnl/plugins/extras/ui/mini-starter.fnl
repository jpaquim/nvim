[{1 :goolord/alpha-nvim :enabled false}
 {1 :glepnir/dashboard-nvim :enabled false}
 {1 :echasnovski/mini.starter
  :config (fn [_ config]
            (when (= vim.o.filetype :lazy)
              (vim.cmd.close)
              (vim.api.nvim_create_autocmd :User
                                           {:callback (fn []
                                                        ((. (require :lazy)
                                                            :show)))
                                            :pattern :MiniStarterOpened}))
            (local starter (require :mini.starter))
            (starter.setup config)
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
                                                      (local pad-footer
                                                             (string.rep " " 8))
                                                      (set starter.config.footer
                                                           (.. pad-footer
                                                               "⚡ Neovim loaded "
                                                               stats.count
                                                               " plugins in " ms
                                                               :ms))
                                                      (pcall starter.refresh))
                                          :pattern :LazyVimStarted}))
  :event :VimEnter
  :opts (fn []
          (local logo (table.concat ["            ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z"
                                     "            ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z    "
                                     "            ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z       "
                                     "            ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z         "
                                     "            ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║           "
                                     "            ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝           "]
                                    "\n"))
          (local pad (string.rep " " 22))

          (fn new-section [name action section]
            {: action : name :section (.. pad section)})

          (local starter (require :mini.starter))
          (local config
                 {:content_hooks [(starter.gen_hook.adding_bullet (.. pad
                                                                      "░ ")
                                                                  false)
                                  (starter.gen_hook.aligning :center :center)]
                  :evaluate_single true
                  :header logo
                  :items [(new-section "Find file" "Telescope find_files"
                                       :Telescope)
                          (new-section "Recent files" "Telescope oldfiles"
                                       :Telescope)
                          (new-section "Grep text" "Telescope live_grep"
                                       :Telescope)
                          (new-section :init.lua "e $MYVIMRC" :Config)
                          (new-section :Extras :LazyExtras :Config)
                          (new-section :Lazy :Lazy :Config)
                          (new-section "New file" "ene | startinsert" :Built-in)
                          (new-section :Quit :qa :Built-in)
                          (new-section "Session restore"
                                       "lua require(\"persistence\").load()"
                                       :Session)]})
          config)
  :version false}]

