[[:Olical/conjure]
 {1 :nvim-cmp
  :opts (fn [_ opts] (table.insert opts.sources 1 {:name :conjure}))}
 {1 :nvim-treesitter/nvim-treesitter
  :opts (fn [_ opts]
          (when (= (type opts.ensure_installed) :table)
            (vim.list_extend opts.ensure_installed [:fennel])))}
 [:janet-lang/janet.vim]]

