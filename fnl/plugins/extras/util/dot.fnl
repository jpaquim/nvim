(local xdg-config (or vim.env.XDG_CONFIG_HOME (.. vim.env.HOME :/.config)))

(fn have [path]
  (not= (vim.loop.fs_stat (.. xdg-config "/" path)) nil))

[{1 :luckasRanarison/tree-sitter-hypr
  :build ":TSUpdate hypr"
  :config (fn []
            (vim.filetype.add {:pattern {".*/hypr/.*%.conf" :hypr}})
            (tset ((. (require :nvim-treesitter.parsers) :get_parser_configs))
                  :hypr
                  {:filetype :hypr
                   :install_info {:branch :master
                                  :files [:src/parser.c]
                                  :url "https://github.com/luckasRanarison/tree-sitter-hypr"}}))
  :enabled (have :hypr)
  :event "BufRead */hypr/*.conf"}
 {1 :nvim-treesitter/nvim-treesitter
  :opts (fn [_ opts]
          (fn add [lang]
            (when (not= (type opts.ensure_installed) :table)
              (table.insert opts.ensure_installed lang)))

          (vim.filetype.add {:extension {:rasi :rasi}
                             :pattern {:.*/kitty/*.conf :bash
                                       :.*/mako/config :dosini
                                       :.*/waybar/config :jsonc}})
          (add :git_config)
          (when (have :fish) (add :fish))
          (when (or (have :rofi) (have :wofi)) (add :rasi)))}]

