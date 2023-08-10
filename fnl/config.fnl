(local Util (require :util))

(local M {})

(set M.version :10.0.0)

(local defaults {:colorscheme (fn []
                                ((. (require :tokyonight) :load)))
                 :defaults {:autocmds true :keymaps true}
                 :icons {:dap {:Breakpoint " "
                               :BreakpointCondition " "
                               :BreakpointRejected [" " :DiagnosticError]
                               :LogPoint ".>"
                               :Stopped ["󰁕 "
                                         :DiagnosticWarn
                                         :DapStoppedLine]}
                         :diagnostics {:Error " "
                                       :Hint " "
                                       :Info " "
                                       :Warn " "}
                         :git {:added " " :modified " " :removed " "}
                         :kinds {:Array " "
                                 :Boolean "󰨙 "
                                 :Class " "
                                 :Codeium "󰘦 "
                                 :Collapsed " "
                                 :Color " "
                                 :Constant "󰏿 "
                                 :Constructor " "
                                 :Control " "
                                 :Copilot " "
                                 :Enum " "
                                 :EnumMember " "
                                 :Event " "
                                 :Field " "
                                 :File " "
                                 :Folder " "
                                 :Function "󰊕 "
                                 :Interface " "
                                 :Key " "
                                 :Keyword " "
                                 :Method "󰊕 "
                                 :Module " "
                                 :Namespace "󰦮 "
                                 :Null " "
                                 :Number "󰎠 "
                                 :Object " "
                                 :Operator " "
                                 :Package " "
                                 :Property " "
                                 :Reference " "
                                 :Snippet " "
                                 :String " "
                                 :Struct "󰆼 "
                                 :Text " "
                                 :TypeParameter " "
                                 :Unit " "
                                 :Value " "
                                 :Variable "󰀫 "}
                         :misc {:dots "󰇘"}}
                 :kind_filter {:default [:Class
                                         :Constructor
                                         :Enum
                                         :Field
                                         :Function
                                         :Interface
                                         :Method
                                         :Module
                                         :Namespace
                                         :Package
                                         :Property
                                         :Struct
                                         :Trait]
                               :lua [:Class
                                     :Constructor
                                     :Enum
                                     :Field
                                     :Function
                                     :Interface
                                     :Method
                                     :Module
                                     :Namespace
                                     :Property
                                     :Struct
                                     :Trait]}})

(set M.json {:data {:extras {} :version nil}})

(fn M.json.load []
  (let [path (.. (vim.fn.stdpath :config) :/lazyvim.json)
        f (io.open path :r)]
    (when f
      (local data (f:read :*a))
      (f:close)
      (local (ok json)
             (pcall vim.json.decode data {:luanil {:array true :object true}}))
      (when ok
        (set M.json.data (vim.tbl_deep_extend :force M.json.data (or json {})))))))

(fn M.json.save []
  (let [path (.. (vim.fn.stdpath :config) :/lazyvim.json)
        f (io.open path :w)]
    (when f (f:write (vim.json.encode M.json.data)) (f:close))))

(var options nil)

(fn M.setup [opts]
  (set options (or (vim.tbl_deep_extend :force defaults (or opts {})) {}))
  (local lazy-autocmds (= (vim.fn.argc (- 1)) 0))
  (when (not lazy-autocmds) (M.load :autocmds))
  (local group (vim.api.nvim_create_augroup :LazyVim {:clear true}))
  (vim.api.nvim_create_autocmd :User
                               {:callback (fn []
                                            (when lazy-autocmds
                                              (M.load :autocmds))
                                            (M.load :keymaps)
                                            (Util.format.setup)
                                            (vim.api.nvim_create_user_command :LazyRoot
                                                                              (fn []
                                                                                (Util.root.info))
                                                                              {:desc "LazyVim roots for the current buffer"})
                                            (vim.api.nvim_create_user_command :LazyExtras
                                                                              (fn []
                                                                                (Util.extras.show))
                                                                              {:desc "Manage LazyVim extras"}))
                                : group
                                :pattern :VeryLazy})
  (Util.track :colorscheme)
  (Util.try (fn []
              (if (= (type M.colorscheme) :function) (M.colorscheme)
                  (vim.cmd.colorscheme M.colorscheme)))
            {:msg "Could not load your colorscheme"
             :on_error (fn [msg] (Util.error msg)
                         (vim.cmd.colorscheme :habamax))})
  (Util.track))

(fn M.get_kind_filter [buf]
  (set-forcibly! buf (or (and (or (= buf nil) (= buf 0))
                              (vim.api.nvim_get_current_buf))
                         buf))
  (local ft (. vim.bo buf :filetype))
  (when (= M.kind_filter false) (lua "return "))
  (or (. M.kind_filter ft) M.kind_filter.default))

(fn M.load [name]
  (fn _load [mod]
    (when (. ((. (require :lazy.core.cache) :find) mod) 1)
      (Util.try (fn [] (require mod)) {:msg (.. "Failed loading " mod)})))

  (when (or (. M.defaults name) (= name :options)) (_load (.. :config. name)))
  (_load (.. :config. name))
  (when (= vim.bo.filetype :lazy) (vim.cmd "do VimResized"))
  (local pattern (.. :LazyVim (: (name:sub 1 1) :upper) (name:sub 2)))
  (vim.api.nvim_exec_autocmds :User {:modeline false : pattern}))

(set M.did_init false)

(fn M.init []
  (when M.did_init (lua "return "))
  (set M.did_init true)
  (local plugin (. (require :lazy.core.config) :spec :plugins :LazyVim))
  (when plugin (vim.opt.rtp:append plugin.dir))
  (tset package.preload :plugins.lsp.format
        (fn []
          (Util.deprecate "require(\"plugins.lsp.format\")"
                          "require(\"util\").format")
          Util.format))
  ((. (require :util) :lazy_notify))
  (M.load :options)
  (Util.plugin.setup)
  (M.json.load))

(setmetatable M {:__index (fn [_ key]
                            (when (= options nil)
                              (let [___antifnl_rtn_1___ (. (vim.deepcopy defaults)
                                                           key)]
                                (lua "return ___antifnl_rtn_1___")))
                            (. options key))})

M

