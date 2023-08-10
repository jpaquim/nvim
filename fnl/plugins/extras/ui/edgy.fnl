[{1 :folke/edgy.nvim
  :event :VeryLazy
  :keys [{1 :<leader>ue
          2 (fn []
              ((. (require :edgy) :toggle)))
          :desc "Edgy Toggle"}
         {1 :<leader>uE
          2 (fn []
              ((. (require :edgy) :select)))
          :desc "Edgy Select Window"}]
  :opts (fn []
          (local opts {:bottom [{:filter (fn [buf win]
                                           (= (. (vim.api.nvim_win_get_config win)
                                                 :relative)
                                              ""))
                                 :ft :toggleterm
                                 :size {:height 0.4}}
                                {:filter (fn [buf win]
                                           (= (. (vim.api.nvim_win_get_config win)
                                                 :relative)
                                              ""))
                                 :ft :noice
                                 :size {:height 0.4}}
                                {:filter (fn [buf]
                                           (not (. vim.b buf :lazyterm_cmd)))
                                 :ft :lazyterm
                                 :size {:height 0.4}
                                 :title :LazyTerm}
                                :Trouble
                                {:ft :qf :title :QuickFix}
                                {:filter (fn [buf]
                                           (= (. vim.bo buf :buftype) :help))
                                 :ft :help
                                 :size {:height 20}}
                                {:ft :spectre_panel :size {:height 0.4}}
                                {:ft :neotest-output-panel
                                 :size {:height 15}
                                 :title "Neotest Output"}]
                       :keys {:<c-Down> (fn [win] (win:resize :height (- 2)))
                              :<c-Left> (fn [win] (win:resize :width (- 2)))
                              :<c-Right> (fn [win] (win:resize :width 2))
                              :<c-Up> (fn [win] (win:resize :height 2))}
                       :left [{:filter (fn [buf]
                                         (= (. vim.b buf :neo_tree_source)
                                            :filesystem))
                               :ft :neo-tree
                               :open (fn [] (vim.api.nvim_input :<esc><space>e))
                               :pinned true
                               :size {:height 0.5}
                               :title :Neo-Tree}
                              {:ft :neotest-summary :title "Neotest Summary"}
                              {:filter (fn [buf]
                                         (= (. vim.b buf :neo_tree_source)
                                            :git_status))
                               :ft :neo-tree
                               :open "Neotree position=right git_status"
                               :pinned true
                               :title "Neo-Tree Git"}
                              {:filter (fn [buf]
                                         (= (. vim.b buf :neo_tree_source)
                                            :buffers))
                               :ft :neo-tree
                               :open "Neotree position=top buffers"
                               :pinned true
                               :title "Neo-Tree Buffers"}
                              :neo-tree]})
          opts)}
 {1 :nvim-telescope/telescope.nvim
  :optional true
  :opts {:defaults {:get_selection_window (fn []
                                            ((. (require :edgy) :goto_main))
                                            0)}}}
 {1 :nvim-neo-tree/neo-tree.nvim
  :optional true
  :opts (fn [_ opts]
          (set opts.open_files_do_not_replace_types
               (or opts.open_files_do_not_replace_types
                   [:terminal :Trouble :qf :Outline]))
          (table.insert opts.open_files_do_not_replace_types :edgy))}
 {1 :akinsho/bufferline.nvim
  :optional true
  :opts (fn []
          (local Offset (require :bufferline.offset))
          (when (not Offset.edgy)
            (local get Offset.get)
            (set Offset.get (fn []
                              (when package.loaded.edgy
                                (local layout
                                       (. (require :edgy.config) :layout))
                                (local ret
                                       {:left ""
                                        :left_size 0
                                        :right ""
                                        :right_size 0})
                                (each [_ pos (ipairs [:left :right])]
                                  (local sb (. layout pos))
                                  (when (and sb (> (length sb.wins) 0))
                                    (local title
                                           (.. " Sidebar"
                                               (string.rep " "
                                                           (- sb.bounds.width 8))))
                                    (tset ret pos
                                          (.. "%#EdgyTitle#" title "%*"
                                              "%#WinSeparator#│%*"))
                                    (tset ret (.. pos :_size) sb.bounds.width)))
                                (set ret.total_size
                                     (+ ret.left_size ret.right_size))
                                (when (> ret.total_size 0) (lua "return ret")))
                              (get)))
            (set Offset.edgy true)))}]

