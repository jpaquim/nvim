(local M (setmetatable {} {:__call (fn [m ...] (m.open ...))}))

(local terminals {})

(fn M.open [cmd opts]
  (set-forcibly! opts
                 (vim.tbl_deep_extend :force
                                      {:ft :lazyterm
                                       :size {:height 0.9 :width 0.9}}
                                      (or opts {}) {:persistent true}))
  (local termkey (vim.inspect {:cmd (or cmd :shell)
                               :count vim.v.count1
                               :cwd opts.cwd
                               :env opts.env}))
  (if (and (. terminals termkey) (: (. terminals termkey) :buf_valid))
      (: (. terminals termkey) :toggle)
      (do
        (tset terminals termkey ((. (require :lazy.util) :float_term) cmd opts))
        (local buf (. terminals termkey :buf))
        (tset (. vim.b buf) :lazyterm_cmd cmd)
        (when (= opts.esc_esc false)
          (vim.keymap.set :t :<esc> :<esc> {:buffer buf :nowait true}))
        (when (= opts.ctrl_hjkl false)
          (vim.keymap.set :t :<c-h> :<c-h> {:buffer buf :nowait true})
          (vim.keymap.set :t :<c-j> :<c-j> {:buffer buf :nowait true})
          (vim.keymap.set :t :<c-k> :<c-k> {:buffer buf :nowait true})
          (vim.keymap.set :t :<c-l> :<c-l> {:buffer buf :nowait true}))
        (vim.api.nvim_create_autocmd :BufEnter
                                     {:buffer buf
                                      :callback (fn [] (vim.cmd.startinsert))})))
  (. terminals termkey))

M

