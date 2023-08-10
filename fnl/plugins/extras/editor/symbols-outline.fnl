(local Util (require :util))

[{1 :simrat39/symbols-outline.nvim
  :cmd :SymbolsOutline
  :keys [{1 :<leader>cs 2 :<cmd>SymbolsOutline<cr> :desc "Symbols Outline"}]
  :opts (fn []
          (local Config (require :config))
          (local defaults (. (require :symbols-outline.config) :defaults))
          (local opts {:symbol_blacklist {} :symbols {}})
          (each [kind symbol (pairs defaults.symbols)]
            (tset opts.symbols kind
                  {:hl symbol.hl
                   :icon (or (. Config.icons.kinds kind) symbol.icon)})
            (when (not (vim.tbl_contains Config.kind_filter.default kind))
              (table.insert opts.symbol_blacklist kind)))
          opts)}
 {1 :folke/edgy.nvim
  :optional true
  :opts (fn [_ opts]
          (local edgy-idx (Util.plugin.extra_idx :ui.edgy))
          (local symbols-idx (Util.plugin.extra_idx :editor.symbols-outline))
          (when (and edgy-idx (> edgy-idx symbols-idx))
            (Util.warn "The `edgy.nvim` extra must be **imported** before the `symbols-outline.nvim` extra to work properly."
                       {:title :LazyVim}))
          (set opts.right (or opts.right {}))
          (table.insert opts.right
                        {:ft :Outline
                         :open :SymbolsOutline
                         :pinned true
                         :title "Symbols Outline"}))}]

