(local Util (require :util))

(local M (setmetatable {} {:__call (fn [m ...] (m.telescope ...))}))

(fn M.telescope [builtin opts]
  (let [params {: builtin : opts}]
    (fn []
      (set-forcibly! builtin params.builtin)
      (set-forcibly! opts params.opts)
      (set-forcibly! opts
                     (vim.tbl_deep_extend :force {:cwd (Util.root)}
                                          (or opts {})))
      (when (= builtin :files)
        (if (vim.loop.fs_stat (.. (or opts.cwd (vim.loop.cwd)) :/.git))
            (do
              (set opts.show_untracked true)
              (set-forcibly! builtin :git_files))
            (set-forcibly! builtin :find_files)))
      (when (and opts.cwd (not= opts.cwd (vim.loop.cwd)))
        (set opts.attach_mappings (fn [_ map]
                                    (map :i :<a-c>
                                         (fn []
                                           (let [action-state (require :telescope.actions.state)
                                                 line (action-state.get_current_line)]
                                             ((M.telescope params.builtin
                                                           (vim.tbl_deep_extend :force
                                                                                {}
                                                                                (or params.opts
                                                                                    {})
                                                                                {:cwd false
                                                                                 :default_text line}))))))
                                    true)))
      ((. (require :telescope.builtin) builtin) opts))))

M

