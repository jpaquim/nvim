[{1 :stevearc/conform.nvim
  :cmd :ConformInfo
  :config (fn [_ opts]
            (set opts.formatters (or opts.formatters {}))
            (each [name formatter (pairs opts.formatters)]
              (when (= (type formatter) :table)
                (local (ok defaults)
                       (pcall require (.. :conform.formatters. name)))
                (when (and ok (= (type defaults) :table))
                  (tset opts.formatters name
                        (vim.tbl_deep_extend :force {} defaults formatter)))))
            ((. (require :conform) :setup) opts))
  :dependencies [:mason.nvim]
  :init (fn []
          (set vim.o.formatexpr "v:lua.require'conform'.formatexpr()")
          ((. (require :util) :on_very_lazy) (fn []
                                               ((. (require :util) :format
                                                   :register) {:format (fn [buf]
                                                                                                                                                    ((. (require :conform)
                                                                                                                                                        :format) {:bufnr buf}))
                                                                                                                                          :name :conform.nvim
                                                                                                                                          :primary true
                                                                                                                                          :priority 100
                                                                                                                                          :sources (fn [buf]
                                                                                                                                                     (local ret
                                                                                                                                                            ((. (require :conform)
                                                                                                                                                                :list_formatters) buf))
                                                                                                                                                     (vim.tbl_map (fn [v]
                                                                                                                                                                    v.name)
                                                                                                                                                                  ret))}))))
  :keys [{1 :<leader>cF
          2 (fn []
              ((. (require :conform) :format) {:formatters [:injected]}))
          :desc "Format Injected Langs"
          :mode [:n :v]}]
  :lazy true
  :opts {:formatters {:injected {:options {:ignore_errors true}}}
         :formatters_by_ft {:fish [:fish_indent] :lua [:stylua] :sh [:shfmt]}}}]

