(fn augroup [name]
  (vim.api.nvim_create_augroup (.. :lazyvim_ name) {:clear true}))

(vim.api.nvim_create_autocmd [:FocusGained :TermClose :TermLeave]
                             {:command :checktime :group (augroup :checktime)})

(vim.api.nvim_create_autocmd :TextYankPost
                             {:callback (fn [] (vim.highlight.on_yank))
                              :group (augroup :highlight_yank)})

(vim.api.nvim_create_autocmd [:VimResized]
                             {:callback (fn []
                                          (local current-tab (vim.fn.tabpagenr))
                                          (vim.cmd "tabdo wincmd =")
                                          (vim.cmd (.. "tabnext " current-tab)))
                              :group (augroup :resize_splits)})

(vim.api.nvim_create_autocmd :BufReadPost
                             {:callback (fn [event]
                                          (local exclude [:gitcommit])
                                          (local buf event.buf)
                                          (when (or (vim.tbl_contains exclude
                                                                      (. vim.bo
                                                                         buf
                                                                         :filetype))
                                                    (. vim.b buf
                                                       :lazyvim_last_loc))
                                            (lua "return "))
                                          (tset (. vim.b buf) :lazyvim_last_loc
                                                true)
                                          (local mark
                                                 (vim.api.nvim_buf_get_mark buf
                                                                            "\""))
                                          (local lcount
                                                 (vim.api.nvim_buf_line_count buf))
                                          (when (and (> (. mark 1) 0)
                                                     (<= (. mark 1) lcount))
                                            (pcall vim.api.nvim_win_set_cursor
                                                   0 mark)))
                              :group (augroup :last_loc)})

(vim.api.nvim_create_autocmd :FileType
                             {:callback (fn [event]
                                          (tset (. vim.bo event.buf) :buflisted
                                                false)
                                          (vim.keymap.set :n :q :<cmd>close<cr>
                                                          {:buffer event.buf
                                                           :silent true}))
                              :group (augroup :close_with_q)
                              :pattern [:PlenaryTestPopup
                                        :help
                                        :lspinfo
                                        :man
                                        :notify
                                        :qf
                                        :query
                                        :spectre_panel
                                        :startuptime
                                        :tsplayground
                                        :neotest-output
                                        :checkhealth
                                        :neotest-summary
                                        :neotest-output-panel]})

(vim.api.nvim_create_autocmd :FileType
                             {:callback (fn [] (set vim.opt_local.wrap true)
                                          (set vim.opt_local.spell true))
                              :group (augroup :wrap_spell)
                              :pattern [:gitcommit :markdown]})

(vim.api.nvim_create_autocmd [:BufWritePre]
                             {:callback (fn [event]
                                          (when (event.match:match "^%w%w+://")
                                            (lua "return "))
                                          (local file
                                                 (or (vim.loop.fs_realpath event.match)
                                                     event.match))
                                          (vim.fn.mkdir (vim.fn.fnamemodify file
                                                                            ":p:h")
                                                        :p))
                              :group (augroup :auto_create_dir)})

(vim.api.nvim_create_autocmd [:BufReadPost]
                             {:callback (fn [] (set vim.o.syntax :wast))
                              :pattern [:*.wat]})

