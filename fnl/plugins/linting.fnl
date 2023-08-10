[{1 :mfussenegger/nvim-lint
  :config (fn [_ opts]
            (local M {})
            (local lint (require :lint))
            (each [name linter (pairs opts.linters)]
              (when (and (= (type linter) :table)
                         (= (type lint.linters) :table))
                (tset lint.linters name
                      (vim.tbl_deep_extend :force (. lint.linters name) linter))))
            (set lint.linters_by_ft opts.linters_by_ft)

            (fn M.debounce [ms ___fn___]
              (local timer (vim.loop.new_timer))
              (fn [...]
                (local argv [...])
                (timer:start ms 0
                             (fn [] (timer:stop)
                               ((vim.schedule_wrap ___fn___) (unpack argv))))))

            (fn M.lint []
              (var names (or (. lint.linters_by_ft vim.bo.filetype) {}))
              (local ctx {:filename (vim.api.nvim_buf_get_name 0)})
              (set ctx.dirname (vim.fn.fnamemodify ctx.filename ":h"))
              (set names (vim.tbl_filter (fn [name]
                                           (local linter (. lint.linters name))
                                           (and linter
                                                (not (and (and (= (type linter)
                                                                  :table)
                                                               linter.condition)
                                                          (not (linter.condition ctx))))))
                                         names))
              (when (> (length names) 0) (lint.try_lint names)))

            (vim.api.nvim_create_autocmd opts.events
                                         {:callback (M.debounce 100 M.lint)
                                          :group (vim.api.nvim_create_augroup :nvim-lint
                                                                              {:clear true})}))
  :event :LazyFile
  :opts {:events [:BufWritePost :BufReadPost :InsertLeave]
         :linters {}
         :linters_by_ft {:fish [:fish]}}}]

