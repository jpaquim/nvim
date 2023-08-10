[{1 :L3MON4D3/LuaSnip
  :build (or (and (not (jit.os:find :Windows))
                  "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp")
             nil)
  :dependencies {1 :rafamadriz/friendly-snippets
                 :config (fn []
                           ((. (require :luasnip.loaders.from_vscode)
                               :lazy_load)))}
  :keys [{1 :<tab>
          2 (fn []
              (or (and ((. (require :luasnip) :jumpable) 1)
                       :<Plug>luasnip-jump-next) :<tab>))
          :expr true
          :mode :i
          :silent true}
         {1 :<tab>
          2 (fn []
              ((. (require :luasnip) :jump) 1))
          :mode :s}
         {1 :<s-tab>
          2 (fn []
              ((. (require :luasnip) :jump) (- 1)))
          :mode [:i :s]}]
  :opts {:delete_check_events :TextChanged :history true}}
 {1 :hrsh7th/nvim-cmp
  :config (fn [_ opts]
            (each [_ source (ipairs opts.sources)]
              (set source.group_index (or source.group_index 1)))
            ((. (require :cmp) :setup) opts))
  :dependencies [:hrsh7th/cmp-nvim-lsp
                 :hrsh7th/cmp-buffer
                 :hrsh7th/cmp-path
                 :saadparwaiz1/cmp_luasnip]
  :event :InsertEnter
  :opts (fn []
          (vim.api.nvim_set_hl 0 :CmpGhostText {:default true :link :Comment})
          (local cmp (require :cmp))
          (local defaults ((require :cmp.config.default)))
          {:completion {:completeopt "menu,menuone,noinsert"}
           :experimental {:ghost_text {:hl_group :CmpGhostText}}
           :formatting {:format (fn [_ item]
                                  (local icons
                                         (. (require :config) :icons :kinds))
                                  (when (. icons item.kind)
                                    (set item.kind
                                         (.. (. icons item.kind) item.kind)))
                                  item)}
           :mapping (cmp.mapping.preset.insert {:<C-CR> (fn [fallback]
                                                          (cmp.abort)
                                                          (fallback))
                                                :<C-Space> (cmp.mapping.complete)
                                                :<C-b> (cmp.mapping.scroll_docs (- 4))
                                                :<C-e> (cmp.mapping.abort)
                                                :<C-f> (cmp.mapping.scroll_docs 4)
                                                :<C-n> (cmp.mapping.select_next_item {:behavior cmp.SelectBehavior.Insert})
                                                :<C-p> (cmp.mapping.select_prev_item {:behavior cmp.SelectBehavior.Insert})
                                                :<CR> (cmp.mapping.confirm {:select true})
                                                :<S-CR> (cmp.mapping.confirm {:behavior cmp.ConfirmBehavior.Replace
                                                                              :select true})})
           :snippet {:expand (fn [args]
                               ((. (require :luasnip) :lsp_expand) args.body))}
           :sorting defaults.sorting
           :sources (cmp.config.sources [{:name :nvim_lsp}
                                         {:name :luasnip}
                                         {:name :path}]
                                        [{:name :buffer}])})
  :version false}
 {1 :echasnovski/mini.pairs
  :event :VeryLazy
  :keys [{1 :<leader>up
          2 (fn []
              (local Util (require :lazy.core.util))
              (set vim.g.minipairs_disable (not vim.g.minipairs_disable))
              (if vim.g.minipairs_disable
                  (Util.warn "Disabled auto pairs" {:title :Option})
                  (Util.info "Enabled auto pairs" {:title :Option})))
          :desc "Toggle auto pairs"}]
  :opts {}}
 {1 :echasnovski/mini.surround
  :keys (fn [_ keys]
          (local plugin (. (require :lazy.core.config) :spec :plugins
                           :mini.surround))
          (local opts
                 ((. (require :lazy.core.plugin) :values) plugin :opts false))
          (var mappings
               [{1 opts.mappings.add :desc "Add surrounding" :mode [:n :v]}
                {1 opts.mappings.delete :desc "Delete surrounding"}
                {1 opts.mappings.find :desc "Find right surrounding"}
                {1 opts.mappings.find_left :desc "Find left surrounding"}
                {1 opts.mappings.highlight :desc "Highlight surrounding"}
                {1 opts.mappings.replace :desc "Replace surrounding"}
                {1 opts.mappings.update_n_lines
                 :desc "Update `MiniSurround.config.n_lines`"}])
          (set mappings (vim.tbl_filter (fn [m]
                                          (and (. m 1) (> (length (. m 1)) 0)))
                                        mappings))
          (vim.list_extend mappings keys))
  :opts {:mappings {:add :gsa
                    :delete :gsd
                    :find :gsf
                    :find_left :gsF
                    :highlight :gsh
                    :replace :gsr
                    :update_n_lines :gsn}}}
 {1 :JoosepAlviste/nvim-ts-context-commentstring
  :lazy true
  :opts {:enable_autocmd false}}
 {1 :echasnovski/mini.comment
  :event :VeryLazy
  :opts {:options {:custom_commentstring (fn []
                                           (or ((. (require :ts_context_commentstring.internal)
                                                   :calculate_commentstring))
                                               vim.bo.commentstring))}}}
 {1 :echasnovski/mini.ai
  :config (fn [_ opts]
            ((. (require :mini.ai) :setup) opts)
            ((. (require :util) :on_load) :which-key.nvim
                                          (fn []
                                            (local i
                                                   {" " :Whitespace
                                                    "\"" "Balanced \""
                                                    "'" "Balanced '"
                                                    "(" "Balanced ("
                                                    ")" "Balanced ) including white-space"
                                                    :<lt> "Balanced <"
                                                    :> "Balanced > including white-space"
                                                    :? "User Prompt"
                                                    "[" "Balanced ["
                                                    "]" "Balanced ] including white-space"
                                                    :_ :Underscore
                                                    "`" "Balanced `"
                                                    :a :Argument
                                                    :b "Balanced ), ], }"
                                                    :c :Class
                                                    :f :Function
                                                    :o "Block, conditional, loop"
                                                    :q "Quote `, \", '"
                                                    :t :Tag
                                                    "{" "Balanced {"
                                                    "}" "Balanced } including white-space"})
                                            (local a (vim.deepcopy i))
                                            (each [k v (pairs a)]
                                              (tset a k
                                                    (v:gsub " including.*" "")))
                                            (local ic (vim.deepcopy i))
                                            (local ac (vim.deepcopy a))
                                            (each [key name (pairs {:l :Last
                                                                    :n :Next})]
                                              (tset i key
                                                    (vim.tbl_extend :force
                                                                    {:name (.. "Inside "
                                                                               name
                                                                               " textobject")}
                                                                    ic))
                                              (tset a key
                                                    (vim.tbl_extend :force
                                                                    {:name (.. "Around "
                                                                               name
                                                                               " textobject")}
                                                                    ac)))
                                            ((. (require :which-key) :register) {: a
                                                                                 : i
                                                                                 :mode [:o
                                                                                        :x]}))))
  :event :VeryLazy
  :opts (fn []
          (local ai (require :mini.ai))
          {:custom_textobjects {:c (ai.gen_spec.treesitter {:a "@class.outer"
                                                            :i "@class.inner"}
                                                           {})
                                :f (ai.gen_spec.treesitter {:a "@function.outer"
                                                            :i "@function.inner"}
                                                           {})
                                :o (ai.gen_spec.treesitter {:a ["@block.outer"
                                                                "@conditional.outer"
                                                                "@loop.outer"]
                                                            :i ["@block.inner"
                                                                "@conditional.inner"
                                                                "@loop.inner"]}
                                                           {})
                                :t ["<([%p%w]-)%f[^<%w][^<>]->.-</%1>"
                                    "^<.->().*()</[^/]->$"]}
           :n_lines 500})}]

