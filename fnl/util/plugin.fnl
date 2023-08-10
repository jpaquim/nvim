(local Plugin (require :lazy.core.plugin))

(local Util (require :util))

(local M {})

(set M.use_lazy_file true)

(set M.lazy_file_events [:BufReadPost :BufNewFile :BufWritePre])

(set M.deprecated_extras
     {:plugins.extras.formatting.conform "`conform.nvim` is now the default **LazyVim** formatter."
      :plugins.extras.linting.nvim-lint "`nvim-lint` is now the default **LazyVim** linter."
      :plugins.extras.ui.dashboard "`dashboard.nvim` is now the default **LazyVim** starter."})

(set M.deprecated_modules
     {:null-ls :lsp.none-ls
      :nvim-navic :editor.navic
      :nvim-navic.lib :editor.navic})

(set M.renames {:jose-elias-alvarez/null-ls.nvim :nvimtools/none-ls.nvim
                :null-ls.nvim :none-ls.nvim
                :romgrk/nvim-treesitter-context :nvim-treesitter/nvim-treesitter-context
                :windwp/nvim-spectre :nvim-pack/nvim-spectre})

(fn M.setup []
  (M.fix_imports)
  (M.fix_renames)
  (M.lazy_file)
  (table.insert package.loaders (fn [module]
                                  (when (. M.deprecated_modules module)
                                    (Util.warn (: "`%s` is no longer included by default in **LazyVim**.
Please install the `%s` extra if you still want to use it."
                                                  :format module
                                                  (. M.deprecated_modules
                                                     module))
                                               {:title :LazyVim})
                                    (fn [])))))

(fn M.extra_idx [name]
  (let [Config (require :lazy.core.config)]
    (each [i extra (ipairs Config.spec.modules)]
      (when (= extra (.. :plugins.extras. name)) (lua "return i")))))

(fn M.lazy_file []
  (set M.use_lazy_file (and M.use_lazy_file (> (vim.fn.argc (- 1)) 0)))
  (local Event (require :lazy.core.handler.event))
  (if M.use_lazy_file (do
                        (set Event.mappings.LazyFile
                             {:event :User :id :LazyFile :pattern :LazyFile})
                        (tset Event.mappings "User LazyFile"
                              Event.mappings.LazyFile))
      (do
        (set Event.mappings.LazyFile
             {:event [:BufReadPost :BufNewFile :BufWritePre] :id :LazyFile})
        (tset Event.mappings "User LazyFile" Event.mappings.LazyFile)
        (lua "return ")))
  (var events {})

  (fn load []
    (when (= (length events) 0) (lua "return "))
    (vim.api.nvim_del_augroup_by_name :lazy_file)
    (local skips {})
    (each [_ event (ipairs events)]
      (tset skips event.event
            (or (. skips event.event) (Event.get_augroups event.event))))
    (vim.api.nvim_exec_autocmds :User {:modeline false :pattern :LazyFile})
    (each [_ event (ipairs events)]
      (Event.trigger {:buf event.buf
                      :data event.data
                      :event event.event
                      :exclude (. skips event.event)})
      (when (. vim.bo event.buf :filetype)
        (Event.trigger {:buf event.buf :event :FileType})))
    (vim.api.nvim_exec_autocmds :CursorMoved {:modeline false})
    (set events {}))

  (global load (vim.schedule_wrap load))
  (vim.api.nvim_create_autocmd M.lazy_file_events
                               {:callback (fn [event]
                                            (table.insert events event)
                                            (load))
                                :group (vim.api.nvim_create_augroup :lazy_file
                                                                    {:clear true})}))

(fn M.fix_imports []
  (set Plugin.Spec.import
       (Util.inject.args Plugin.Spec.import
                         (fn [_ spec]
                           (var dep
                                (. M.deprecated_extras (and spec spec.import)))
                           (when dep
                             (set dep
                                  (.. dep "\n"
                                      "Please remove the extra to hide this warning."))
                             (Util.warn dep
                                        {:once true
                                         :stacklevel 6
                                         :stacktrace true
                                         :title :LazyVim})
                             false)))))

(fn M.fix_renames []
  (set Plugin.Spec.add
       (Util.inject.args Plugin.Spec.add
                         (fn [self plugin]
                           (when (= (type plugin) :table)
                             (when (. M.renames (. plugin 1))
                               (Util.warn (: "Plugin `%s` was renamed to `%s`.
Please update your config for `%s`"
                                             :format (. plugin 1)
                                             (. M.renames (. plugin 1))
                                             (or self.importing :LazyVim))
                                          {:title :LazyVim})
                               (tset plugin 1 (. M.renames (. plugin 1)))))))))

M

