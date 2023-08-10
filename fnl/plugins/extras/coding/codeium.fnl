[{1 :nvim-cmp
  :dependencies [{1 :Exafunction/codeium.nvim
                  :build ":Codeium Auth"
                  :cmd :Codeium
                  :opts {}}]
  :opts (fn [_ opts]
          (table.insert opts.sources 1
                        {:group_index 1 :name :codeium :priority 100}))}
 {1 :nvim-lualine/lualine.nvim
  :event :VeryLazy
  :optional true
  :opts (fn [_ opts]
          (var started false)

          (fn status []
            (when (not (. package.loaded :cmp)) (lua "return "))
            (each [_ s (ipairs (. (require :cmp) :core :sources))]
              (when (= s.name :codeium)
                (if (s.source:is_available) (set started true)
                    (let [___antifnl_rtn_1___ (or (and started :error) nil)]
                      (lua "return ___antifnl_rtn_1___")))
                (when (= s.status s.SourceStatus.FETCHING)
                  (lua "return \"pending\""))
                (lua "return \"ok\""))))

          (local Util (require :util))
          (local colors
                 {:error (Util.ui.fg :DiagnosticError)
                  :ok (Util.ui.fg :Special)
                  :pending (Util.ui.fg :DiagnosticWarn)})
          (table.insert opts.sections.lualine_x 2
                        {1 (fn [] (. (require :config) :icons :kinds :Codeium))
                         :color (fn []
                                  (or (. colors (status)) colors.ok))
                         :cond (fn [] (not= (status) nil))}))}]

