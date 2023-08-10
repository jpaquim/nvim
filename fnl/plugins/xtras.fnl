(local Config (require :config))

(local prios {:dap.core 1
              :editor.aerial 100
              :editor.symbols-outline 100
              :test.core 1})

(table.sort Config.json.data.extras
            (fn [a b]
              (let [pa (or (. prios a) 10)
                    pb (or (. prios b) 10)]
                (when (= pa pb)
                  (let [___antifnl_rtn_1___ (< a b)]
                    (lua "return ___antifnl_rtn_1___")))
                (< pa pb))))

(vim.tbl_map (fn [extra] {:import (.. :plugins.extras. extra)})
             Config.json.data.extras)

