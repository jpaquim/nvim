[{1 :williamboman/mason.nvim
  :opts (fn [_ opts] (table.insert opts.ensure_installed :prettierd))}
 {1 :nvimtools/none-ls.nvim
  :optional true
  :opts (fn [_ opts]
          (local nls (require :null-ls))
          (set opts.sources (or opts.sources {}))
          (table.insert opts.sources nls.builtins.formatting.prettierd))}
 {1 :stevearc/conform.nvim
  :optional true
  :opts {:formatters_by_ft {:css [[:prettierd :prettier]]
                            :graphql [[:prettierd :prettier]]
                            :handlebars [[:prettierd :prettier]]
                            :html [[:prettierd :prettier]]
                            :javascript [[:prettierd :prettier]]
                            :javascriptreact [[:prettierd :prettier]]
                            :json [[:prettierd :prettier]]
                            :jsonc [[:prettierd :prettier]]
                            :less [[:prettierd :prettier]]
                            :markdown [[:prettierd :prettier]]
                            :markdown.mdx [[:prettierd :prettier]]
                            :scss [[:prettierd :prettier]]
                            :typescript [[:prettierd :prettier]]
                            :typescriptreact [[:prettierd :prettier]]
                            :vue [[:prettierd :prettier]]
                            :yaml [[:prettierd :prettier]]}}}]

