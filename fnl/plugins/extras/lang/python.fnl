[{1 :nvim-treesitter/nvim-treesitter
  :opts (fn [_ opts]
          (when (= (type opts.ensure_installed) :table)
            (vim.list_extend opts.ensure_installed [:ninja :python :rst :toml])))}
 {1 :neovim/nvim-lspconfig
  :opts {:servers {:pyright {} :ruff_lsp {}}
         :setup {:ruff_lsp (fn []
                             ((. (require :util) :lsp :on_attach) (fn [client
                                                                       _]
                                                                    (when (= client.name
                                                                             :ruff_lsp)
                                                                      (set client.server_capabilities.hoverProvider
                                                                           false)))))}}}
 {1 :nvim-neotest/neotest
  :dependencies [:nvim-neotest/neotest-python]
  :optional true
  :opts {:adapters {:neotest-python {}}}}
 {1 :mfussenegger/nvim-dap
  :dependencies {1 :mfussenegger/nvim-dap-python
                 :config (fn []
                           (local path
                                  (: ((. (require :mason-registry) :get_package) :debugpy)
                                     :get_install_path))
                           ((. (require :dap-python) :setup) (.. path
                                                                 :/venv/bin/python)))
                 :keys [{1 :<leader>dPt
                         2 (fn []
                             ((. (require :dap-python) :test_method)))
                         :desc "Debug Method"}
                        {1 :<leader>dPc
                         2 (fn []
                             ((. (require :dap-python) :test_class)))
                         :desc "Debug Class"}]}
  :optional true}
 {1 :linux-cultist/venv-selector.nvim
  :cmd :VenvSelect
  :keys [{1 :<leader>cv 2 "<cmd>:VenvSelect<cr>" :desc "Select VirtualEnv"}]
  :opts (fn [_ opts]
          (when ((. (require :util) :has) :nvim-dap-python)
            (set opts.dap_enabled true))
          (vim.tbl_deep_extend :force opts {:name [:venv :.venv :env :.env]}))}]

