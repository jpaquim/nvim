{1 :mfussenegger/nvim-dap
 :dependencies [{1 :jbyuki/one-small-step-for-vimkind
                 :config (fn []
                           (local dap (require :dap))
                           (set dap.adapters.nlua
                                (fn [callback conf]
                                  (local adapter
                                         {:host (or conf.host :127.0.0.1)
                                          :port (or conf.port 8086)
                                          :type :server})
                                  (when conf.start_neovim
                                    (local dap-run dap.run)
                                    (set dap.run
                                         (fn [c] (set adapter.port c.port)
                                           (set adapter.host c.host)))
                                    ((. (require :osv) :run_this))
                                    (set dap.run dap-run))
                                  (callback adapter)))
                           (set dap.configurations.lua
                                [{:name "Run this file"
                                  :request :attach
                                  :start_neovim {}
                                  :type :nlua}
                                 {:name "Attach to running Neovim instance (port = 8086)"
                                  :port 8086
                                  :request :attach
                                  :type :nlua}]))}]}

