(local Util (require :util))

(local M (setmetatable {} {:__call (fn [m] (m.get))}))

(set M.spec [:lsp [:.git :lua] :cwd])

(set M.detectors {})

(fn M.detectors.cwd [] [(vim.loop.cwd)])

(fn M.detectors.lsp [buf]
  (let [bufpath (M.bufpath buf)]
    (when (not bufpath)
      (let [___antifnl_rtn_1___ {}] (lua "return ___antifnl_rtn_1___")))
    (local roots {})
    (each [_ client (pairs (Util.lsp.get_clients {:bufnr buf}))]
      (local workspace client.config.workspace_folders)
      (each [_ ws (pairs (or workspace {}))]
        (tset roots (+ (length roots) 1) (vim.uri_to_fname ws.uri)))
      (when client.config.root_dir
        (tset roots (+ (length roots) 1) client.config.root_dir)))
    (vim.tbl_filter (fn [path]
                      (set-forcibly! path (Util.norm path))
                      (and path (= (bufpath:find path 1 true) 1)))
                    roots)))

(fn M.detectors.pattern [buf patterns]
  (set-forcibly! patterns (or (and (= (type patterns) :string) [patterns])
                              patterns))
  (local path (or (M.bufpath buf) (vim.loop.cwd)))
  (local pattern (. (vim.fs.find patterns {: path :upward true}) 1))
  (or (and pattern [(vim.fs.dirname pattern)]) {}))

(fn M.bufpath [buf]
  (M.realpath (vim.api.nvim_buf_get_name (assert buf))))

(fn M.realpath [path]
  (when (or (= path "") (= path nil)) (lua "return nil"))
  (set-forcibly! path (or (vim.loop.fs_realpath path) path))
  (Util.norm path))

(fn M.resolve [spec]
  (if (. M.detectors spec)
      (let [___antifnl_rtn_1___ (. M.detectors spec)]
        (lua "return ___antifnl_rtn_1___")) (= (type spec) :function)
      (lua "return spec"))
  (fn [buf] (M.detectors.pattern buf spec)))

(fn M.detect [opts]
  (set-forcibly! opts (or opts {}))
  (set opts.spec (or (or opts.spec
                         (and (= (type vim.g.root_spec) :table) vim.g.root_spec))
                     M.spec))
  (set opts.buf (or (and (or (= opts.buf nil) (= opts.buf 0))
                         (vim.api.nvim_get_current_buf))
                    opts.buf))
  (local ret {})
  (each [_ spec (ipairs opts.spec)]
    (var paths ((M.resolve spec) opts.buf))
    (set paths (or paths {}))
    (set paths (or (and (= (type paths) :table) paths) [paths]))
    (local roots {})
    (each [_ p (ipairs paths)]
      (local pp (M.realpath p))
      (when (and pp (not (vim.tbl_contains roots pp)))
        (tset roots (+ (length roots) 1) pp)))
    (table.sort roots (fn [a b] (> (length a) (length b))))
    (when (> (length roots) 0)
      (tset ret (+ (length ret) 1) {:paths roots : spec})
      (when (= opts.all false) (lua :break))))
  ret)

(fn M.info []
  (let [spec (or (and (= (type vim.g.root_spec) :table) vim.g.root_spec) M.spec)
        roots (M.detect {:all true})
        lines {}]
    (var first true)
    (each [_ root (ipairs roots)]
      (each [_ path (ipairs root.paths)]
        (tset lines (+ (length lines) 1)
              (: "- [%s] `%s` **(%s)**" :format (or (and first :x) " ") path
                 (or (and (= (type root.spec) :table)
                          (table.concat root.spec ", "))
                     root.spec)))
        (set first false)))
    (tset lines (+ (length lines) 1) "```lua")
    (tset lines (+ (length lines) 1)
          (.. "vim.g.root_spec = " (vim.inspect spec)))
    (tset lines (+ (length lines) 1) "```")
    ((. (require :util) :info) lines {:title "LazyVim Roots"})
    (or (and (. roots 1) (. roots 1 :paths 1)) (vim.loop.cwd))))

(fn M.get []
  (let [roots (M.detect {:all false})]
    (or (and (. roots 1) (. roots 1 :paths 1)) (vim.loop.cwd))))

(set M.pretty_cache {})

(fn M.pretty_path []
  (var path (vim.fn.expand "%:p"))
  (when (= path "") (lua "return \"\""))
  (set path (Util.norm path))
  (when (. M.pretty_cache path)
    (let [___antifnl_rtn_1___ (. M.pretty_cache path)]
      (lua "return ___antifnl_rtn_1___")))
  (local cache-key path)
  (local cwd (or (M.realpath (vim.loop.cwd)) ""))
  (if (= (path:find cwd 1 true) 1) (set path (path:sub (+ (length cwd) 2)))
      (let [roots (M.detect {:spec [:.git]})
            root (or (and (. roots 1) (. roots 1 :paths 1)) nil)]
        (when root
          (set path (path:sub (+ (length (vim.fs.dirname root)) 2))))))
  (local sep (package.config:sub 1 1))
  (var parts (vim.split path "[\\/]"))
  (when (> (length parts) 3)
    (set parts [(. parts 1)
                "…"
                (. parts (- (length parts) 1))
                (. parts (length parts))]))
  (local ret (table.concat parts sep))
  (tset M.pretty_cache cache-key ret)
  ret)

M

