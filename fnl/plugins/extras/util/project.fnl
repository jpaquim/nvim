[{1 :telescope.nvim
  :dependencies [{1 :ahmedkhalf/project.nvim
                  :config (fn [_ opts]
                            ((. (require :project_nvim) :setup) opts)
                            ((. (require :util) :on_load) :telescope.nvim
                                                          (fn []
                                                            ((. (require :telescope)
                                                                :load_extension) :projects))))
                  :event :VeryLazy
                  :keys [{1 :<leader>fp
                          2 "<Cmd>Telescope projects<CR>"
                          :desc :Projects}]
                  :opts {}}]}
 {1 :goolord/alpha-nvim
  :optional true
  :opts (fn [_ dashboard]
          (local button
                 (dashboard.button :p (.. " " " Projects")
                                   ":Telescope projects <CR>"))
          (set button.opts.hl :AlphaButtons)
          (set button.opts.hl_shortcut :AlphaShortcut)
          (table.insert dashboard.section.buttons.val 4 button))}
 {1 :echasnovski/mini.starter
  :optional true
  :opts (fn [_ opts]
          (local items
                 [{:action "Telescope projects"
                   :name :Projects
                   :section (.. (string.rep " " 22) :Telescope)}])
          (vim.list_extend opts.items items))}
 {1 :glepnir/dashboard-nvim
  :optional true
  :opts (fn [_ opts]
          (local projects {:action "Telescope projects"
                           :desc " Projects"
                           :icon " "
                           :key :p})
          (table.insert opts.config.center 3 projects))}]

