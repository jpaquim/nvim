(local Lazy-util (require :lazy.core.util))

(local M {})

(local deprecated {:fg :ui
                   :float_term [:terminal :open]
                   :get_clients :lsp
                   :get_root [:root :get]
                   :on_attach :lsp
                   :on_rename :lsp
                   :root_patterns [:root :patterns]
                   :toggle [:toggle :option]
                   :toggle_diagnostics [:toggle :diagnostics]
                   :toggle_number [:toggle :number]})

(setmetatable M {:__index (fn [t k]
                            (when (. Lazy-util k)
                              (let [___antifnl_rtn_1___ (. Lazy-util k)]
                                (lua "return ___antifnl_rtn_1___")))
                            (local dep (. deprecated k))
                            (when dep
                              (local mod
                                     (or (and (= (type dep) :table) (. dep 1))
                                         dep))
                              (local key
                                     (or (and (= (type dep) :table) (. dep 2))
                                         k))
                              (M.deprecate (.. "require(\"util\")." k)
                                           (.. "require(\"util\")." mod "." key))
                              (tset t mod (require (.. :util. mod)))
                              (let [___antifnl_rtn_1___ (. t mod key)]
                                (lua "return ___antifnl_rtn_1___")))
                            (tset t k (require (.. :util. k)))
                            (. t k))})

(fn M.has [plugin]
  (not= (. (require :lazy.core.config) :spec :plugins plugin) nil))

(fn M.on_very_lazy [___fn___]
  (vim.api.nvim_create_autocmd :User
                               {:callback (fn [] (___fn___))
                                :pattern :VeryLazy}))

(fn M.opts [name]
  (let [plugin (. (require :lazy.core.config) :plugins name)]
    (when (not plugin)
      (let [___antifnl_rtn_1___ {}] (lua "return ___antifnl_rtn_1___")))
    (local Plugin (require :lazy.core.plugin))
    (Plugin.values plugin :opts false)))

(fn M.deprecate [old new]
  (M.warn (: "`%s` is deprecated. Please use `%s` instead" :format old new)
          {:once true :stacklevel 6 :stacktrace true :title :LazyVim}))

(fn M.lazy_notify []
  (let [notifs {}]
    (fn temp [...] (table.insert notifs (vim.F.pack_len ...)))

    (local orig vim.notify)
    (set vim.notify temp)
    (local timer (vim.loop.new_timer))
    (local check (assert (vim.loop.new_check)))

    (fn replay []
      (timer:stop)
      (check:stop)
      (when (= vim.notify temp) (set vim.notify orig))
      (vim.schedule (fn []
                      (each [_ notif (ipairs notifs)]
                        (vim.notify (vim.F.unpack_len notif))))))

    (check:start (fn [] (when (not= vim.notify temp) (replay))))
    (timer:start 500 0 replay)))

(fn M.on_load [name ___fn___]
  (let [Config (require :lazy.core.config)]
    (if (and (. Config.plugins name) (. Config.plugins name "_" :loaded))
        (___fn___ name)
        (vim.api.nvim_create_autocmd :User
                                     {:callback (fn [event]
                                                  (when (= event.data name)
                                                    (___fn___ name)
                                                    true))
                                      :pattern :LazyLoad}))))

(fn M.changelog []
  (let [lv (. (require :lazy.core.config) :plugins :LazyVim)
        float ((. (require :lazy.util) :open) (.. lv.dir :/CHANGELOG.md))]
    (tset (. vim.wo float.win) :spell false)
    (tset (. vim.wo float.win) :wrap false)
    (vim.diagnostic.disable float.buf)))

(fn M.safe_keymap_set [mode lhs rhs opts]
  (let [keys (. (require :lazy.core.handler) :handlers :keys)]
    (var modes (or (and (= (type mode) :string) [mode]) mode))
    (set modes (vim.tbl_filter (fn [m]
                                 (not (and keys.have (keys:have lhs m))))
                               modes))
    (when (> (length modes) 0)
      (set-forcibly! opts (or opts {}))
      (set opts.silent (not= opts.silent false))
      (when (and opts.remap (not vim.g.vscode)) (set opts.remap nil))
      (vim.keymap.set modes lhs rhs opts))))

M

