[{1 :folke/flash.nvim :enabled false :optional true}
 {1 :ggandor/flit.nvim
  :enabled true
  :keys (fn []
          (local ret {})
          (each [_ key (ipairs [:f :F :t :T])]
            (tset ret (+ (length ret) 1) {1 key :desc key :mode [:n :x :o]}))
          ret)
  :opts {:labeled_modes :nx}}
 {1 :ggandor/leap.nvim
  :config (fn [_ opts]
            (local leap (require :leap))
            (each [k v (pairs opts)] (tset leap.opts k v))
            (leap.add_default_mappings true)
            (vim.keymap.del [:x :o] :x)
            (vim.keymap.del [:x :o] :X))
  :enabled true
  :keys [{1 :s :desc "Leap forward to" :mode [:n :x :o]}
         {1 :S :desc "Leap backward to" :mode [:n :x :o]}
         {1 :gs :desc "Leap from windows" :mode [:n :x :o]}]}
 {1 :echasnovski/mini.surround
  :opts {:mappings {:add :gza
                    :delete :gzd
                    :find :gzf
                    :find_left :gzF
                    :highlight :gzh
                    :replace :gzr
                    :update_n_lines :gzn}}}
 {1 :tpope/vim-repeat :event :VeryLazy}]

