[{1 :echasnovski/mini.animate
  :event :VeryLazy
  :opts (fn []
          (var mouse-scrolled false)
          (each [_ scroll (ipairs [:Up :Down])]
            (local key (.. :<ScrollWheel scroll ">"))
            (vim.keymap.set ["" :i] key (fn [] (set mouse-scrolled true) key)
                            {:expr true}))
          (local animate (require :mini.animate))
          {:resize {:timing (animate.gen_timing.linear {:duration 100
                                                        :unit :total})}
           :scroll {:subscroll (animate.gen_subscroll.equal {:predicate (fn [total-scroll]
                                                                          (when mouse-scrolled
                                                                            (set mouse-scrolled
                                                                                 false)
                                                                            (lua "return false"))
                                                                          (> total-scroll
                                                                             1))})
                    :timing (animate.gen_timing.linear {:duration 150
                                                        :unit :total})}})}]

