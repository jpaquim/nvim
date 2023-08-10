[{1 :zbirenbaum/copilot.lua
  :build ":Copilot auth"
  :cmd :Copilot
  :opts {:filetypes {:help true :markdown true}
         :panel {:enabled false}
         :suggestion {:enabled false}}}
 {1 :nvim-lualine/lualine.nvim
  :event :VeryLazy
  :optional true
  :opts (fn [_ opts]
          (local Util (require :util))
          (local colors
                 {"" (Util.ui.fg :Special)
                  :InProgress (Util.ui.fg :DiagnosticWarn)
                  :Normal (Util.ui.fg :Special)
                  :Warning (Util.ui.fg :DiagnosticError)})
          (table.insert opts.sections.lualine_x 2
                        {1 (fn []
                             (local icon
                                    (. (require :config) :icons :kinds :Copilot))
                             (local status
                                    (. (require :copilot.api) :status :data))
                             (.. icon (or status.message "")))
                         :color (fn []
                                  (when (not (. package.loaded :copilot))
                                    (lua "return "))
                                  (local status
                                         (. (require :copilot.api) :status
                                            :data))
                                  (or (. colors status.status) (. colors "")))
                         :cond (fn []
                                 (when (not (. package.loaded :copilot))
                                   (lua "return "))
                                 (local (ok clients)
                                        (pcall (. (require :util) :lsp
                                                  :get_clients)
                                               {:bufnr 0 :name :copilot}))
                                 (when (not ok) (lua "return false"))
                                 (and ok (> (length clients) 0)))}))}
 {1 :nvim-cmp
  :dependencies [{1 :zbirenbaum/copilot-cmp
                  :config (fn [_ opts]
                            (local copilot-cmp (require :copilot_cmp))
                            (copilot-cmp.setup opts)
                            ((. (require :util) :lsp :on_attach) (fn [client]
                                                                   (when (= client.name
                                                                            :copilot)
                                                                     (copilot-cmp._on_insert_enter {})))))
                  :dependencies :copilot.lua
                  :opts {}}]
  :opts (fn [_ opts]
          (table.insert opts.sources 1
                        {:group_index 1 :name :copilot :priority 100}))}]

