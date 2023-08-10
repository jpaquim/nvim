[{1 :nvim-treesitter/nvim-treesitter
  :opts (fn [_ opts]
          (vim.list_extend opts.ensure_installed [:elixir :heex :eex]))}
 {1 :williamboman/mason.nvim
  :opts (fn [_ opts] (vim.list_extend opts.ensure_installed [:elixir-ls]))}
 {1 :nvim-neotest/neotest
  :dependencies [:jfpedroza/neotest-elixir]
  :optional true
  :opts {:adapters {:neotest-elixir {}}}}
 {1 :nvimtools/none-ls.nvim
  :optional true
  :opts (fn [_ opts]
          (when (= (vim.fn.executable :credo) 0) (lua "return "))
          (local nls (require :null-ls))
          (set opts.sources
               (vim.list_extend (or opts.sources {})
                                [nls.builtins.diagnostics.credo])))}
 {1 :mfussenegger/nvim-lint
  :optional true
  :opts (fn [_ opts]
          (when (= (vim.fn.executable :credo) 0) (lua "return "))
          (set opts.linters_by_ft {:elixir [:credo]}))}]

