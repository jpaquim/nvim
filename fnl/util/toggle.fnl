(local Util (require :util))

(local M {})

(fn M.option [option silent ___values___]
  (when ___values___
    (if (= (: (. vim.opt_local option) :get) (. ___values___ 1))
        (tset vim.opt_local option (. ___values___ 2))
        (tset vim.opt_local option (. ___values___ 1)))
    (let [___antifnl_rtns_1___ [(Util.info (.. "Set " option " to "
                                               (: (. vim.opt_local option) :get))
                                           {:title :Option})]]
      (lua "return (table.unpack or _G.unpack)(___antifnl_rtns_1___)")))
  (tset vim.opt_local option (not (: (. vim.opt_local option) :get)))
  (when (not silent)
    (if (: (. vim.opt_local option) :get)
        (Util.info (.. "Enabled " option) {:title :Option})
        (Util.warn (.. "Disabled " option) {:title :Option}))))

(var nu {:number true :relativenumber true})

(fn M.number []
  (if (or (vim.opt_local.number:get) (vim.opt_local.relativenumber:get))
      (do
        (set nu
             {:number (vim.opt_local.number:get)
              :relativenumber (vim.opt_local.relativenumber:get)})
        (set vim.opt_local.number false)
        (set vim.opt_local.relativenumber false)
        (Util.warn "Disabled line numbers" {:title :Option}))
      (do
        (set vim.opt_local.number nu.number)
        (set vim.opt_local.relativenumber nu.relativenumber)
        (Util.info "Enabled line numbers" {:title :Option}))))

(var enabled true)

(fn M.diagnostics []
  (set enabled (not enabled))
  (if enabled
      (do
        (vim.diagnostic.enable)
        (Util.info "Enabled diagnostics" {:title :Diagnostics}))
      (do
        (vim.diagnostic.disable)
        (Util.warn "Disabled diagnostics" {:title :Diagnostics}))))

(setmetatable M {:__call (fn [m ...] (m.option ...))})

M

