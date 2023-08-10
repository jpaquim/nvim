{1 :echasnovski/mini.files
 :config (fn [_ opts]
           ((. (require :mini.files) :setup) opts)
           (var show-dotfiles true)

           (fn filter-show [fs-entry] true)

           (fn filter-hide [fs-entry] (not (vim.startswith fs-entry.name ".")))

           (fn toggle-dotfiles []
             (set show-dotfiles (not show-dotfiles))
             (local new-filter (or (and show-dotfiles filter-show) filter-hide))
             ((. (require :mini.files) :refresh) {:content {:filter new-filter}}))

           (vim.api.nvim_create_autocmd :User
                                        {:callback (fn [args]
                                                     (local buf-id
                                                            args.data.buf_id)
                                                     (vim.keymap.set :n :g.
                                                                     toggle-dotfiles
                                                                     {:buffer buf-id}))
                                         :pattern :MiniFilesBufferCreate})
           (vim.api.nvim_create_autocmd :User
                                        {:callback (fn [event]
                                                     ((. (require :util) :lsp
                                                         :on_rename) event.data.from
                                                                                                                                                   event.data.to))
                                         :pattern :MiniFilesActionRename}))
 :keys [{1 :<leader>fm
         2 (fn []
             ((. (require :mini.files) :open) (vim.api.nvim_buf_get_name 0)
                                              true))
         :desc "Open mini.files (directory of current file)"}
        {1 :<leader>fM
         2 (fn []
             ((. (require :mini.files) :open) (vim.loop.cwd) true))
         :desc "Open mini.files (cwd)"}]
 :opts {:options {:use_as_default_explorer false}
        :windows {:preview true :width_focus 30 :width_preview 30}}}

