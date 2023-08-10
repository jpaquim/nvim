(fn get-args [config]
  (let [args (or (or (and (= (type config.args) :function)
                          (or (config.args) {}))
                     config.args) {})]
    (set-forcibly! config (vim.deepcopy config))
    (set config.args
         (fn []
           (let [new-args (vim.fn.input "Run with args: "
                                        (table.concat args " "))]
             (vim.split (vim.fn.expand new-args) " "))))
    config))

{1 :mfussenegger/nvim-dap
 :config (fn []
           (local Config (require :config))
           (vim.api.nvim_set_hl 0 :DapStoppedLine {:default true :link :Visual})
           (each [name sign (pairs Config.icons.dap)]
             (set-forcibly! sign (or (and (= (type sign) :table) sign) [sign]))
             (vim.fn.sign_define (.. :Dap name)
                                 {:linehl (. sign 3)
                                  :numhl (. sign 3)
                                  :text (. sign 1)
                                  :texthl (or (. sign 2) :DiagnosticInfo)})))
 :dependencies [{1 :rcarriga/nvim-dap-ui
                 :config (fn [_ opts]
                           (local dap (require :dap))
                           (local dapui (require :dapui))
                           (dapui.setup opts)
                           (tset dap.listeners.after.event_initialized
                                 :dapui_config (fn [] (dapui.open {})))
                           (tset dap.listeners.before.event_terminated
                                 :dapui_config (fn [] (dapui.close {})))
                           (tset dap.listeners.before.event_exited
                                 :dapui_config (fn [] (dapui.close {}))))
                 :keys [{1 :<leader>du
                         2 (fn []
                             ((. (require :dapui) :toggle) {}))
                         :desc "Dap UI"}
                        {1 :<leader>de
                         2 (fn []
                             ((. (require :dapui) :eval)))
                         :desc :Eval
                         :mode [:n :v]}]
                 :opts {}}
                {1 :theHamsta/nvim-dap-virtual-text :opts {}}
                {1 :folke/which-key.nvim
                 :optional true
                 :opts {:defaults {:<leader>d {:name :+debug}}}}
                {1 :jay-babu/mason-nvim-dap.nvim
                 :cmd [:DapInstall :DapUninstall]
                 :dependencies :mason.nvim
                 :opts {:automatic_installation true
                        :ensure_installed {}
                        :handlers {}}}]
 :keys [{1 :<leader>dB
         2 (fn []
             ((. (require :dap) :set_breakpoint) (vim.fn.input "Breakpoint condition: ")))
         :desc "Breakpoint Condition"}
        {1 :<leader>db
         2 (fn []
             ((. (require :dap) :toggle_breakpoint)))
         :desc "Toggle Breakpoint"}
        {1 :<leader>dc
         2 (fn []
             ((. (require :dap) :continue)))
         :desc :Continue}
        {1 :<leader>da
         2 (fn []
             ((. (require :dap) :continue) {:before get-args}))
         :desc "Run with Args"}
        {1 :<leader>dC
         2 (fn []
             ((. (require :dap) :run_to_cursor)))
         :desc "Run to Cursor"}
        {1 :<leader>dg
         2 (fn []
             ((. (require :dap) :goto_)))
         :desc "Go to line (no execute)"}
        {1 :<leader>di
         2 (fn []
             ((. (require :dap) :step_into)))
         :desc "Step Into"}
        {1 :<leader>dj
         2 (fn []
             ((. (require :dap) :down)))
         :desc :Down}
        {1 :<leader>dk
         2 (fn []
             ((. (require :dap) :up)))
         :desc :Up}
        {1 :<leader>dl
         2 (fn []
             ((. (require :dap) :run_last)))
         :desc "Run Last"}
        {1 :<leader>do
         2 (fn []
             ((. (require :dap) :step_out)))
         :desc "Step Out"}
        {1 :<leader>dO
         2 (fn []
             ((. (require :dap) :step_over)))
         :desc "Step Over"}
        {1 :<leader>dp
         2 (fn []
             ((. (require :dap) :pause)))
         :desc :Pause}
        {1 :<leader>dr
         2 (fn []
             ((. (require :dap) :repl :toggle)))
         :desc "Toggle REPL"}
        {1 :<leader>ds
         2 (fn []
             ((. (require :dap) :session)))
         :desc :Session}
        {1 :<leader>dt
         2 (fn []
             ((. (require :dap) :terminate)))
         :desc :Terminate}
        {1 :<leader>dw
         2 (fn []
             ((. (require :dap.ui.widgets) :hover)))
         :desc :Widgets}]}

