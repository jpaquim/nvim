[{1 :nvim-treesitter/nvim-treesitter
  :build ":TSUpdate"
  :cmd [:TSUpdateSync :TSUpdate :TSInstall]
  :config (fn [_ opts]
            (when (= (type opts.ensure_installed) :table)
              (local added {})
              (set opts.ensure_installed
                   (vim.tbl_filter (fn [lang]
                                     (when (. added lang) (lua "return false"))
                                     (tset added lang true)
                                     true)
                                   opts.ensure_installed)))
            ((. (require :nvim-treesitter.configs) :setup) opts))
  :dependencies [{1 :nvim-treesitter/nvim-treesitter-textobjects
                  :config (fn []
                            (local move
                                   (require :nvim-treesitter.textobjects.move))
                            (local configs (require :nvim-treesitter.configs))
                            (each [name ___fn___ (pairs move)]
                              (when (= (name:find :goto) 1)
                                (tset move name
                                      (fn [q ...]
                                        (when vim.wo.diff
                                          (local config
                                                 (. (configs.get_module :textobjects.move)
                                                    name))
                                          (each [key query (pairs (or config {}))]
                                            (when (and (= q query)
                                                       (key:find "[%]%[][cC]"))
                                              (vim.cmd (.. "normal! " key))
                                              (lua "return "))))
                                        (___fn___ q ...))))))}]
  :event [:LazyFile :VeryLazy]
  :keys [{1 :<c-space> :desc "Increment selection"}
         {1 :<bs> :desc "Decrement selection" :mode :x}]
  :opts {:ensure_installed [:bash
                            :c
                            :diff
                            :html
                            :javascript
                            :jsdoc
                            :json
                            :jsonc
                            :lua
                            :luadoc
                            :luap
                            :markdown
                            :markdown_inline
                            :python
                            :query
                            :regex
                            :toml
                            :tsx
                            :typescript
                            :vim
                            :vimdoc
                            :yaml]
         :highlight {:enable true}
         :incremental_selection {:enable true
                                 :keymaps {:init_selection :<C-space>
                                           :node_decremental :<bs>
                                           :node_incremental :<C-space>
                                           :scope_incremental false}}
         :indent {:enable true}
         :textobjects {:move {:enable true
                              :goto_next_end {"]C" "@class.outer"
                                              "]F" "@function.outer"}
                              :goto_next_start {"]c" "@class.outer"
                                                "]f" "@function.outer"}
                              :goto_previous_end {"[C" "@class.outer"
                                                  "[F" "@function.outer"}
                              :goto_previous_start {"[c" "@class.outer"
                                                    "[f" "@function.outer"}}}}
  :version false}
 {1 :nvim-treesitter/nvim-treesitter-context
  :enabled true
  :event :LazyFile
  :opts {:mode :cursor}}
 {1 :windwp/nvim-ts-autotag :event :InsertEnter :opts {}}]

