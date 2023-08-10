(local Config (require :config))

(local Float (require :lazy.view.float))

(local Lazy-config (require :lazy.core.config))

(local Plugin (require :lazy.core.plugin))

(local Text (require :lazy.view.text))

(local Util (require :util))

(local M {})

(set M.ns (vim.api.nvim_create_namespace :lazyvim.extras))

(set M.state nil)

(fn M.get []
  (set M.state (or M.state Lazy-config.spec.modules))
  (local root (.. Lazy-config.plugins.LazyVim.dir :/lua/lazyvim/plugins/extras))
  (local extras {})
  (Util.walk root
             (fn [path name type]
               (when (and (= type :file) (name:match "%.lua$"))
                 (local extra (: (path:sub (+ (length root) 2) (- 5)) :gsub "/"
                                 "."))
                 (tset extras (+ (length extras) 1) extra))))
  (table.sort extras)
  (vim.tbl_map (fn [extra]
                 (let [modname (.. :plugins.extras. extra)
                       enabled (vim.tbl_contains M.state modname)
                       spec (Plugin.Spec.new {:import (.. :plugins.extras.
                                                          extra)}
                                             {:optional true})
                       plugins {}
                       optional {}]
                   (each [_ p (pairs spec.plugins)]
                     (if p.optional
                         (tset optional (+ (length optional) 1) p.name)
                         (tset plugins (+ (length plugins) 1) p.name)))
                   (table.sort plugins)
                   (table.sort optional)
                   {: enabled
                    :managed (or (vim.tbl_contains Config.json.data.extras
                                                   extra)
                                 (not enabled))
                    :name extra
                    : optional
                    : plugins})) extras))

(local X {})

(fn X.new []
  (let [self (setmetatable {} {:__index X})]
    (set self.float (Float.new {:title "LazyVim Extras"}))
    (self.float:on_key :x (fn [] (self:toggle)) "Toggle extra")
    (set self.diag {})
    (self:update)
    self))

(fn X.diagnostic [self diag]
  (set diag.row (or diag.row (self.text:row)))
  (set diag.severity (or diag.severity vim.diagnostic.severity.INFO))
  (table.insert self.diag diag))

(fn X.toggle [self]
  (let [pos (vim.api.nvim_win_get_cursor self.float.win)]
    (each [_ extra (ipairs self.extras)]
      (when (= extra.row (. pos 1))
        (when (not extra.managed)
          (Util.error "Not managed by LazyExtras. Remove from your config to enable/disable here."
                      {:title :LazyExtras})
          (lua "return "))
        (set extra.enabled (not extra.enabled))
        (set Config.json.data.extras
             (vim.tbl_filter (fn [name] (not= name extra.name))
                             Config.json.data.extras))
        (set M.state (vim.tbl_filter (fn [name]
                                       (not= name
                                             (.. :plugins.extras. extra.name)))
                                     M.state))
        (when extra.enabled
          (table.insert Config.json.data.extras extra.name)
          (tset M.state (+ (length M.state) 1) (.. :plugins.extras. extra.name)))
        (table.sort Config.json.data.extras)
        (Config.json.save)
        (Util.info (.. "`" extra.name "`" " "
                       (or (and extra.enabled :**enabled**) :**disabled**)
                       "\nPlease restart LazyVim to apply the changes.")
                   {:title :LazyExtras})
        (self:update)
        (lua "return ")))))

(fn X.update [self]
  (set self.diag {})
  (set self.extras (M.get))
  (set self.text (Text.new))
  (set self.text.padding 2)
  (self:render)
  (self.text:trim)
  (tset (. vim.bo self.float.buf) :modifiable true)
  (self.text:render self.float.buf)
  (tset (. vim.bo self.float.buf) :modifiable false)
  (vim.diagnostic.set M.ns self.float.buf
                      (vim.tbl_map (fn [diag] (set diag.col 0)
                                     (set diag.lnum (- diag.row 1))
                                     diag)
                                   self.diag)
                      {:signs false :virtual_text true}))

(fn X.render [self]
  (: (: (: (: (self.text:nl) :nl) :append "LazyVim Extras" :LazyH1) :nl) :nl)
  (: (: (: (: (: (: (: (self.text:append "This is a list of all enabled/disabled LazyVim extras."
                                         :LazyComment)
                       :nl) :append
                    "Each extra shows the required and optional plugins it may install."
                    :LazyComment) :nl) :append
              "Enable/disable extras with the " :LazyComment)
           :append :<x> :LazySpecial) :append " key" :LazyComment) :nl)
  (self:section {:enabled true :title :Enabled})
  (self:section {:enabled false :title :Disabled}))

(fn X.extra [self extra]
  (when (not extra.managed)
    (self:diagnostic {:message "Not managed by LazyExtras (config)"
                      :severity vim.diagnostic.severity.WARN}))
  (set extra.row (self.text:row))
  (local hl (or (and extra.managed :LazySpecial) :LazyLocal))
  (if extra.enabled (self.text:append (.. "  "
                                          Lazy-config.options.ui.icons.loaded
                                          " ")
                                      hl)
      (self.text:append (.. "  " Lazy-config.options.ui.icons.not_loaded " ")
                        hl))
  (self.text:append extra.name)
  (each [_ plugin (ipairs extra.plugins)]
    (: (self.text:append " ") :append
       (.. Lazy-config.options.ui.icons.plugin "" plugin) :LazyReasonPlugin))
  (each [_ plugin (ipairs extra.optional)]
    (: (self.text:append " ") :append
       (.. Lazy-config.options.ui.icons.plugin "" plugin) :LazyReasonRequire))
  (self.text:nl))

(fn X.section [self opts]
  (set-forcibly! opts (or opts {}))
  (local extras (vim.tbl_filter (fn [extra]
                                  (or (= opts.enabled nil)
                                      (= extra.enabled opts.enabled)))
                                self.extras))
  (: (: (: (self.text:nl) :append (.. opts.title ":") :LazyH2) :append
        (.. " (" (length extras) ")") :LazyComment) :nl)
  (each [_ extra (ipairs extras)] (self:extra extra)))

(fn M.show [] (X.new))

M

