(local M {})

(local start (or vim.health.start vim.health.report_start))

(local ok (or vim.health.ok vim.health.report_ok))

(local warn (or vim.health.warn vim.health.report_warn))

(local error (or vim.health.error vim.health.report_error))

(fn M.check []
  (start :LazyVim)
  (if (= (vim.fn.has :nvim-0.9.0) 1) (ok "Using Neovim >= 0.9.0")
      (error "Neovim >= 0.9.0 is required"))
  (each [_ cmd (ipairs [:git :rg [:fd :fdfind] :lazygit])]
    (var name (or (and (= (type cmd) :string) cmd) (vim.inspect cmd)))
    (local commands (or (and (= (type cmd) :string) [cmd]) cmd))
    (var found false)
    (each [_ c (ipairs commands)]
      (when (= (vim.fn.executable c) 1) (set name c) (set found true)))
    (if found (ok (: "`%s` is installed" :format name))
        (warn (: "`%s` is not installed" :format name)))))

M

