(local Config (require :config))

(local Util (require :util))

[{1 :stevearc/aerial.nvim
  :event :LazyFile
  :keys [{1 :<leader>cs 2 :<cmd>AerialToggle<cr> :desc "Aerial (Symbols)"}]
  :opts (fn []
          (local lualine (require :lualine.components.aerial))
          (set lualine.format_status
               (Util.inject.args lualine.format_status
                                 (fn [_ symbols]
                                   (each [_ s (ipairs symbols)]
                                     (set s.icon
                                          (or (and s.icon
                                                   (s.icon:gsub "%s*$" ""))
                                              nil))))))
          (local icons (vim.deepcopy Config.icons.kinds))
          (set icons.lua {:Package icons.Control})
          (var filter-kind false)
          (when Config.kind_filter
            (set filter-kind (assert (vim.deepcopy Config.kind_filter)))
            (set filter-kind._ filter-kind.default)
            (set filter-kind.default nil))
          (local opts {:attach_mode :global
                       :backends [:lsp :treesitter :markdown :man]
                       :filter_kind filter-kind
                       :guides {:last_item "└╴"
                                :mid_item "├╴"
                                :nested_top "│ "
                                :whitespace "  "}
                       : icons
                       :layout {:resize_to_content false
                                :win_opts {:signcolumn :yes
                                           :statuscolumn " "
                                           :winhl "Normal:NormalFloat,FloatBorder:NormalFloat,SignColumn:SignColumnSB"}}
                       :show_guides true})
          opts)}
 {1 :nvim-telescope/telescope.nvim
  :keys [{1 :<leader>ss
          2 "<cmd>Telescope aerial<cr>"
          :desc "Goto Symbol (Aerial)"}]
  :optional true
  :opts (fn []
          (Util.on_load :telescope.nvim
                        (fn []
                          ((. (require :telescope) :load_extension) :aerial))))}
 {1 :folke/edgy.nvim
  :optional true
  :opts (fn [_ opts]
          (local edgy-idx (Util.plugin.extra_idx :ui.edgy))
          (local aerial-idx (Util.plugin.extra_idx :editor.aerial))
          (when (and edgy-idx (> edgy-idx aerial-idx))
            (Util.warn "The `edgy.nvim` extra must be **imported** before the `aerial.nvim` extra to work properly."
                       {:title :LazyVim}))
          (set opts.right (or opts.right {}))
          (table.insert opts.right
                        {:ft :aerial
                         :open :AerialOpen
                         :pinned true
                         :title :Aerial}))}
 {1 :nvim-lualine/lualine.nvim
  :optional true
  :opts (fn [_ opts]
          (table.insert opts.sections.lualine_c
                        {1 :aerial
                         :colored true
                         :dense false
                         :dense_sep "."
                         :depth 5
                         :sep " "}))}]

