[{1 :williamboman/mason.nvim
  :opts (fn [_ opts] (table.insert opts.ensure_installed :black))}
 {1 :nvimtools/none-ls.nvim
  :optional true
  :opts (fn [_ opts]
          (local nls (require :null-ls))
          (set opts.sources (or opts.sources {}))
          (table.insert opts.sources nls.builtins.formatting.black))}
 {1 :stevearc/conform.nvim
  :optional true
  :opts {:formatters_by_ft {:python [:black]}}}]

