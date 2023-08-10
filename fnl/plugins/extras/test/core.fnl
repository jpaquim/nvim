[{1 :folke/which-key.nvim
  :optional true
  :opts {:defaults {:<leader>t {:name :+test}}}}
 {1 :nvim-neotest/neotest
  :config (fn [_ opts]
            (local neotest-ns (vim.api.nvim_create_namespace :neotest))
            (vim.diagnostic.config {:virtual_text {:format (fn [diagnostic]
                                                             (local message
                                                                    (: (: (: (diagnostic.message:gsub "\n"
                                                                                                      " ")
                                                                             :gsub
                                                                             "\t"
                                                                             " ")
                                                                          :gsub
                                                                          "%s+"
                                                                          " ")
                                                                       :gsub
                                                                       "^%s+" ""))
                                                             message)}}
                                   neotest-ns)
            (when opts.adapters
              (local adapters {})
              (each [name config (pairs (or opts.adapters {}))]
                (if (= (type name) :number)
                    (do
                      (when (= (type config) :string)
                        (set-forcibly! config (require config)))
                      (tset adapters (+ (length adapters) 1) config))
                    (not= config false)
                    (do
                      (local adapter (require name))
                      (when (and (= (type config) :table)
                                 (not (vim.tbl_isempty config)))
                        (local meta (getmetatable adapter))
                        (if adapter.setup (adapter.setup config)
                            (and meta meta.__call) (adapter config)
                            (error (.. "Adapter " name
                                       " does not support setup"))))
                      (tset adapters (+ (length adapters) 1) adapter))))
              (set opts.adapters adapters))
            ((. (require :neotest) :setup) opts))
  :keys [{1 :<leader>tt
          2 (fn []
              ((. (require :neotest) :run :run) (vim.fn.expand "%")))
          :desc "Run File"}
         {1 :<leader>tT
          2 (fn []
              ((. (require :neotest) :run :run) (vim.loop.cwd)))
          :desc "Run All Test Files"}
         {1 :<leader>tr
          2 (fn []
              ((. (require :neotest) :run :run)))
          :desc "Run Nearest"}
         {1 :<leader>ts
          2 (fn []
              ((. (require :neotest) :summary :toggle)))
          :desc "Toggle Summary"}
         {1 :<leader>to
          2 (fn []
              ((. (require :neotest) :output :open) {:auto_close true
                                                     :enter true}))
          :desc "Show Output"}
         {1 :<leader>tO
          2 (fn []
              ((. (require :neotest) :output_panel :toggle)))
          :desc "Toggle Output Panel"}
         {1 :<leader>tS
          2 (fn []
              ((. (require :neotest) :run :stop)))
          :desc :Stop}]
  :opts {:adapters {}
         :output {:open_on_run true}
         :quickfix {:open (fn []
                            (if ((. (require :util) :has) :trouble.nvim)
                                (vim.cmd "Trouble quickfix") (vim.cmd :copen)))}
         :status {:virtual_text true}}}
 {1 :mfussenegger/nvim-dap
  :keys [{1 :<leader>td
          2 (fn []
              ((. (require :neotest) :run :run) {:strategy :dap}))
          :desc "Debug Nearest"}]
  :optional true}]

