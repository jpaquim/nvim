[{1 :nvim-treesitter/nvim-treesitter
  :opts (fn [_ opts] (vim.list_extend opts.ensure_installed [:ruby]))}
 {1 :williamboman/mason.nvim
  :opts (fn [_ opts] (vim.list_extend opts.ensure_installed [:solargraph]))}
 {1 :neovim/nvim-lspconfig :opts {:servers {:solargraph {}}}}
 {1 :mfussenegger/nvim-dap
  :dependencies {1 :suketa/nvim-dap-ruby
                 :config (fn []
                           ((. (require :dap-ruby) :setup)))}
  :optional true}
 {1 :nvim-neotest/neotest
  :dependencies [:olimorris/neotest-rspec]
  :optional true
  :opts {:adapters {:neotest-rspec {}}}}]

