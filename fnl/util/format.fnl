(local Util (require :util))

(local M (setmetatable {} {:__call (fn [m ...] (m.format ...))}))

(set M.formatters {})

(fn M.register [formatter]
  (tset M.formatters (+ (length M.formatters) 1) formatter)
  (table.sort M.formatters (fn [a b] (> a.priority b.priority))))

(fn M.resolve [buf]
  (set-forcibly! buf (or buf (vim.api.nvim_get_current_buf)))
  (var have-primary false)
  (vim.tbl_map (fn [formatter]
                 (let [sources (formatter.sources buf)
                       active (and (> (length sources) 0)
                                   (or (not formatter.primary)
                                       (not have-primary)))]
                   (set have-primary
                        (or (or have-primary (and active formatter.primary))
                            false))
                   (setmetatable {: active :resolved sources}
                                 {:__index formatter})))
               M.formatters))

(fn M.info [buf]
  (set-forcibly! buf (or buf (vim.api.nvim_get_current_buf)))
  (local gaf (or (= vim.g.autoformat nil) vim.g.autoformat))
  (local baf (. vim.b buf :autoformat))
  (local enabled (M.enabled buf))
  (local lines ["# Status"
                (: "- [%s] global **%s**" :format (or (and gaf :x) " ")
                   (or (and gaf :enabled) :disabled))
                (: "- [%s] buffer **%s**" :format (or (and enabled :x) " ")
                   (or (or (and (= baf nil) :inherit) (and baf :enabled))
                       :disabled))])
  (var have false)
  (each [_ formatter (ipairs (M.resolve buf))]
    (when (> (length formatter.resolved) 0)
      (set have true)
      (tset lines (+ (length lines) 1)
            (.. "\n# " formatter.name
                (or (and formatter.active " ***(active)***") "")))
      (each [_ line (ipairs formatter.resolved)]
        (tset lines (+ (length lines) 1)
              (: "- [%s] **%s**" :format (or (and formatter.active :x) " ")
                 line)))))
  (when (not have)
    (tset lines (+ (length lines) 1)
          "\n***No formatters available for this buffer.***"))
  ((. Util (or (and enabled :info) :warn)) (table.concat lines "\n")
                                           {:title (.. "LazyFormat ("
                                                       (or (and enabled
                                                                :enabled)
                                                           :disabled)
                                                       ")")}))

(fn M.enabled [buf]
  (set-forcibly! buf (or (and (or (= buf nil) (= buf 0))
                              (vim.api.nvim_get_current_buf))
                         buf))
  (local gaf vim.g.autoformat)
  (local baf (. vim.b buf :autoformat))
  (when (not= baf nil) (lua "return baf"))
  (or (= gaf nil) gaf))

(fn M.toggle [buf]
  (if buf (set vim.b.autoformat (not (M.enabled)))
      (do
        (set vim.g.autoformat (not (M.enabled)))
        (set vim.b.autoformat nil)))
  (M.info))

(fn M.format [opts]
  (set-forcibly! opts (or opts {}))
  (local buf (or opts.buf (vim.api.nvim_get_current_buf)))
  (when (not (or (and opts opts.force) (M.enabled buf)))
    (lua "return "))
  (var done false)
  (each [_ formatter (ipairs (M.resolve buf))]
    (when formatter.active
      (set done true)
      (Util.try (fn [] (formatter.format buf))
                {:msg (.. "Formatter `" formatter.name "` failed")})))
  (when (and (and (not done) opts) opts.force)
    (Util.warn "No formatter available" {:title :LazyVim})))

(fn M.health []
  (let [Config (require :lazy.core.config)
        has-plugin (. Config.spec.plugins :none-ls.nvim)
        has-extra (vim.tbl_contains Config.spec.modules
                                    :plugins.extras.lsp.none-ls)]
    (when (and has-plugin (not has-extra))
      (Util.warn ["`conform.nvim` and `nvim-lint` are now the default forrmatters and linters in LazyVim."
                  ""
                  "You can use those plugins together with `none-ls.nvim`,"
                  "but you need to enable the `plugins.extras.lsp.none-ls` extra,"
                  "for formatting to work correctly."
                  ""
                  "In case you no longer want to use `none-ls.nvim`, just remove the spec from your config."]))))

(fn M.setup []
  (M.health)
  (vim.api.nvim_create_autocmd :BufWritePre
                               {:callback (fn [event]
                                            (M.format {:buf event.buf}))
                                :group (vim.api.nvim_create_augroup :LazyFormat
                                                                    {})})
  (vim.api.nvim_create_user_command :LazyFormat
                                    (fn [] (M.format {:force true}))
                                    {:desc "Format selection or buffer"})
  (vim.api.nvim_create_user_command :LazyFormatInfo (fn [] (M.info))
                                    {:desc "Show info about the formatters for the current buffer"}))

M

