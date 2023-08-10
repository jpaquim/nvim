(local M {})

(fn M.get_signs [buf lnum]
  (let [signs (vim.tbl_map (fn [sign]
                             (let [ret (. (vim.fn.sign_getdefined sign.name) 1)]
                               (set ret.priority sign.priority)
                               ret))
                           (. (vim.fn.sign_getplaced buf {:group "*" : lnum}) 1
                              :signs))
        extmarks (vim.api.nvim_buf_get_extmarks buf (- 1) [(- lnum 1) 0]
                                                [(- lnum 1) (- 1)]
                                                {:details true :type :sign})]
    (each [_ extmark (pairs extmarks)]
      (tset signs (+ (length signs) 1)
            {:name (or (. extmark 4 :sign_hl_group) "")
             :priority (. extmark 4 :priority)
             :text (. extmark 4 :sign_text)
             :texthl (. extmark 4 :sign_hl_group)}))
    (table.sort signs (fn [a b] (< (or a.priority 0) (or b.priority 0))))
    signs))

(fn M.get_mark [buf lnum]
  (let [marks (vim.fn.getmarklist buf)]
    (vim.list_extend marks (vim.fn.getmarklist))
    (each [_ mark (ipairs marks)]
      (when (and (and (= (. mark.pos 1) buf) (= (. mark.pos 2) lnum))
                 (mark.mark:match "[a-zA-Z]"))
        (let [___antifnl_rtn_1___ {:text (mark.mark:sub 2)
                                   :texthl :DiagnosticHint}]
          (lua "return ___antifnl_rtn_1___"))))))

(fn M.icon [sign len]
  (set-forcibly! sign (or sign {}))
  (set-forcibly! len (or len 2))
  (var text (vim.fn.strcharpart (or sign.text "") 0 len))
  (set text (.. text (string.rep " " (- len (vim.fn.strchars text)))))
  (or (and sign.texthl (.. "%#" sign.texthl "#" text "%*")) text))

(fn M.foldtext []
  (let [ok (pcall vim.treesitter.get_parser (vim.api.nvim_get_current_buf))]
    (var ret (and (and ok vim.treesitter.foldtext) (vim.treesitter.foldtext)))
    (when (or (not ret) (= (type ret) :string))
      (set ret [[(. (vim.api.nvim_buf_get_lines 0 (- vim.v.lnum 1) vim.v.lnum
                                                false) 1)
                 {}]]))
    (table.insert ret [(.. " " (. (require :config) :icons :misc :dots))])
    (when (not vim.treesitter.foldtext)
      (let [___antifnl_rtns_1___ [(table.concat (vim.tbl_map (fn [line]
                                                               (. line 1))
                                                             ret)
                                                " ")]]
        (lua "return (table.unpack or _G.unpack)(___antifnl_rtns_1___)")))
    ret))

(fn M.statuscolumn []
  (let [win vim.g.statusline_winid]
    (when (= (. vim.wo win :signcolumn) :no) (lua "return \"\""))
    (local buf (vim.api.nvim_win_get_buf win))
    (var (left right fold) nil)
    (each [_ s (ipairs (M.get_signs buf vim.v.lnum))]
      (if (and s.name (s.name:find :GitSign)) (set right s) (set left s)))
    (when (not= vim.v.virtnum 0) (set left nil))
    (vim.api.nvim_win_call win
                           (fn []
                             (when (>= (vim.fn.foldclosed vim.v.lnum) 0)
                               (set fold
                                    {:text (or (. (vim.opt.fillchars:get)
                                                  :foldclose)
                                               "")
                                     :texthl :Folded}))))
    (var nu "")
    (when (and (. vim.wo win :number) (= vim.v.virtnum 0))
      (set nu (or (and (and (. vim.wo win :relativenumber)
                            (not= vim.v.relnum 0))
                       vim.v.relnum) vim.v.lnum)))
    (table.concat [(M.icon (or (M.get_mark buf vim.v.lnum) left))
                   "%="
                   (.. nu " ")
                   (M.icon (or fold right))] "")))

(fn M.fg [name]
  (let [hl (or (and vim.api.nvim_get_hl (vim.api.nvim_get_hl 0 {: name}))
               (vim.api.nvim_get_hl_by_name name true))
        fg (and hl (or hl.fg hl.foreground))]
    (or (and fg {:fg (string.format "#%06x" fg)}) nil)))

M

