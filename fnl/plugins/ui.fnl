[{1 :rcarriga/nvim-notify
  :init (fn []
          (local Util (require :util))
          (when (not (Util.has :noice.nvim))
            (Util.on_very_lazy (fn [] (set vim.notify (require :notify))))))
  :keys [{1 :<leader>un
          2 (fn []
              ((. (require :notify) :dismiss) {:pending true :silent true}))
          :desc "Dismiss all Notifications"}]
  :opts {:max_height (fn [] (math.floor (* vim.o.lines 0.75)))
         :max_width (fn [] (math.floor (* vim.o.columns 0.75)))
         :on_open (fn [win] (vim.api.nvim_win_set_config win {:zindex 100}))
         :timeout 3000}}
 {1 :stevearc/dressing.nvim
  :init (fn []
          (set vim.ui.select
               (fn [...]
                 ((. (require :lazy) :load) {:plugins [:dressing.nvim]})
                 (vim.ui.select ...)))
          (set vim.ui.input (fn [...]
                              ((. (require :lazy) :load) {:plugins [:dressing.nvim]})
                              (vim.ui.input ...))))
  :lazy true}
 {1 :akinsho/bufferline.nvim
  :config (fn [_ opts]
            ((. (require :bufferline) :setup) opts)
            (vim.api.nvim_create_autocmd :BufAdd
                                         {:callback (fn []
                                                      (vim.schedule (fn []
                                                                      (pcall nvim-bufferline))))}))
  :event :VeryLazy
  :keys [{1 :<leader>bp 2 :<Cmd>BufferLineTogglePin<CR> :desc "Toggle pin"}
         {1 :<leader>bP
          2 "<Cmd>BufferLineGroupClose ungrouped<CR>"
          :desc "Delete non-pinned buffers"}]
  :opts {:options {:always_show_bufferline false
                   :close_command (fn [n]
                                    ((. (require :mini.bufremove) :delete) n
                                                                           false))
                   :diagnostics :nvim_lsp
                   :diagnostics_indicator (fn [_ _ diag]
                                            (local icons
                                                   (. (require :config) :icons
                                                      :diagnostics))
                                            (local ret
                                                   (.. (or (and diag.error
                                                                (.. icons.Error
                                                                    diag.error
                                                                    " "))
                                                           "")
                                                       (or (and diag.warning
                                                                (.. icons.Warn
                                                                    diag.warning))
                                                           "")))
                                            (vim.trim ret))
                   :offsets [{:filetype :neo-tree
                              :highlight :Directory
                              :text :Neo-tree
                              :text_align :left}]
                   :right_mouse_command (fn [n]
                                          ((. (require :mini.bufremove) :delete) n
                                                                                 false))}}}
 {1 :nvim-lualine/lualine.nvim
  :event :VeryLazy
  :init (fn []
          (set vim.g.lualine_laststatus vim.o.laststatus)
          (if (> (vim.fn.argc (- 1)) 0) (set vim.o.statusline " ")
              (set vim.o.laststatus 0)))
  :opts (fn []
          (local lualine-require (require :lualine_require))
          (set lualine-require.require require)
          (local icons (. (require :config) :icons))
          (local Util (require :util))
          (set vim.o.laststatus vim.g.lualine_laststatus)
          {:extensions [:neo-tree :lazy]
           :options {:disabled_filetypes {:statusline [:dashboard
                                                       :alpha
                                                       :starter]}
                     :globalstatus true
                     :theme :auto}
           :sections {:lualine_a [:mode]
                      :lualine_b [:branch]
                      :lualine_c [{1 :diagnostics
                                   :symbols {:error icons.diagnostics.Error
                                             :hint icons.diagnostics.Hint
                                             :info icons.diagnostics.Info
                                             :warn icons.diagnostics.Warn}}
                                  {1 :filetype
                                   :icon_only true
                                   :padding {:left 1 :right 0}
                                   :separator ""}
                                  [(fn [] (Util.root.pretty_path))]]
                      :lualine_x [{1 (fn []
                                       ((. (require :noice) :api :status
                                           :command :get)))
                                   :color (Util.ui.fg :Statement)
                                   :cond (fn []
                                           (and (. package.loaded :noice)
                                                ((. (require :noice) :api
                                                    :status :command :has))))}
                                  {1 (fn []
                                       ((. (require :noice) :api :status :mode
                                           :get)))
                                   :color (Util.ui.fg :Constant)
                                   :cond (fn []
                                           (and (. package.loaded :noice)
                                                ((. (require :noice) :api
                                                    :status :mode :has))))}
                                  {1 (fn []
                                       (.. "  " ((. (require :dap) :status))))
                                   :color (Util.ui.fg :Debug)
                                   :cond (fn []
                                           (and (. package.loaded :dap)
                                                (not= ((. (require :dap)
                                                          :status))
                                                      "")))}
                                  {1 (. (require :lazy.status) :updates)
                                   :color (Util.ui.fg :Special)
                                   :cond (. (require :lazy.status) :has_updates)}
                                  {1 :diff
                                   :symbols {:added icons.git.added
                                             :modified icons.git.modified
                                             :removed icons.git.removed}}]
                      :lualine_y [{1 :progress
                                   :padding {:left 1 :right 0}
                                   :separator " "}
                                  {1 :location :padding {:left 0 :right 1}}]
                      :lualine_z [(fn [] (.. " " (os.date "%R")))]}})}
 {1 :lukas-reineke/indent-blankline.nvim
  :event :LazyFile
  :main :ibl
  :opts {:exclude {:filetypes [:help
                               :alpha
                               :dashboard
                               :neo-tree
                               :Trouble
                               :lazy
                               :mason
                               :notify
                               :toggleterm
                               :lazyterm]}
         :indent {:char "│" :tab_char "│"}
         :scope {:enabled false}}}
 {1 :echasnovski/mini.indentscope
  :event :LazyFile
  :init (fn []
          (vim.api.nvim_create_autocmd :FileType
                                       {:callback (fn []
                                                    (set vim.b.miniindentscope_disable
                                                         true))
                                        :pattern [:help
                                                  :alpha
                                                  :dashboard
                                                  :neo-tree
                                                  :Trouble
                                                  :lazy
                                                  :mason
                                                  :notify
                                                  :toggleterm
                                                  :lazyterm]}))
  :opts {:options {:try_as_border true} :symbol "│"}
  :version false}
 {1 :folke/which-key.nvim
  :opts (fn [_ opts]
          (when ((. (require :util) :has) :noice.nvim)
            (tset opts.defaults :<leader>sn {:name :+noice})))}
 {1 :folke/noice.nvim
  :event :VeryLazy
  :keys [{1 :<S-Enter>
          2 (fn []
              ((. (require :noice) :redirect) (vim.fn.getcmdline)))
          :desc "Redirect Cmdline"
          :mode :c}
         {1 :<leader>snl
          2 (fn []
              ((. (require :noice) :cmd) :last))
          :desc "Noice Last Message"}
         {1 :<leader>snh
          2 (fn []
              ((. (require :noice) :cmd) :history))
          :desc "Noice History"}
         {1 :<leader>sna
          2 (fn []
              ((. (require :noice) :cmd) :all))
          :desc "Noice All"}
         {1 :<leader>snd
          2 (fn []
              ((. (require :noice) :cmd) :dismiss))
          :desc "Dismiss All"}
         {1 :<c-f>
          2 (fn []
              (when (not ((. (require :noice.lsp) :scroll) 4))
                :<c-f>))
          :desc "Scroll forward"
          :expr true
          :mode [:i :n :s]
          :silent true}
         {1 :<c-b>
          2 (fn []
              (when (not ((. (require :noice.lsp) :scroll) (- 4)))
                :<c-b>))
          :desc "Scroll backward"
          :expr true
          :mode [:i :n :s]
          :silent true}]
  :opts {:lsp {:override {:cmp.entry.get_documentation true
                          :vim.lsp.util.convert_input_to_markdown_lines true
                          :vim.lsp.util.stylize_markdown true}}
         :presets {:bottom_search true
                   :command_palette true
                   :inc_rename true
                   :long_message_to_split true}
         :routes [{:filter {:any [{:find "%d+L, %d+B"}
                                  {:find "; after #%d+"}
                                  {:find "; before #%d+"}]
                            :event :msg_show}
                   :view :mini}]}}
 {1 :nvim-tree/nvim-web-devicons :lazy true}
 {1 :MunifTanjim/nui.nvim :lazy true}
 {1 :goolord/alpha-nvim
  :enabled (fn []
             ((. (require :util) :warn) ["`dashboard.nvim` is now the default LazyVim starter plugin."
                                         ""
                                         "To keep using `alpha.nvim`, please enable the `plugins.extras.ui.alpha` extra."
                                         "Or to hide this message, remove the alpha spec from your config."])
             false)
  :optional true}
 {1 :glepnir/dashboard-nvim
  :event :VimEnter
  :opts (fn []
          (var logo "           ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
           ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z    
           ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z       
           ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z         
           ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║           
           ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝           
      ")
          (set logo (.. (string.rep "\n" 8) logo "\n\n"))
          (local opts {:config {:center [{:action "Telescope find_files"
                                          :desc " Find file"
                                          :icon " "
                                          :key :f}
                                         {:action "ene | startinsert"
                                          :desc " New file"
                                          :icon " "
                                          :key :n}
                                         {:action "Telescope oldfiles"
                                          :desc " Recent files"
                                          :icon " "
                                          :key :r}
                                         {:action "Telescope live_grep"
                                          :desc " Find text"
                                          :icon " "
                                          :key :g}
                                         {:action "e $MYVIMRC"
                                          :desc " Config"
                                          :icon " "
                                          :key :c}
                                         {:action "lua require(\"persistence\").load()"
                                          :desc " Restore Session"
                                          :icon " "
                                          :key :s}
                                         {:action :LazyExtras
                                          :desc " Lazy Extras"
                                          :icon " "
                                          :key :e}
                                         {:action :Lazy
                                          :desc " Lazy"
                                          :icon "󰒲 "
                                          :key :l}
                                         {:action :qa
                                          :desc " Quit"
                                          :icon " "
                                          :key :q}]
                                :footer (fn []
                                          (local stats
                                                 ((. (require :lazy) :stats)))
                                          (local ms
                                                 (/ (math.floor (+ (* stats.startuptime
                                                                      100)
                                                                   0.5))
                                                    100))
                                          [(.. "⚡ Neovim loaded "
                                               stats.loaded "/" stats.count
                                               " plugins in " ms :ms)])
                                :header (vim.split logo "\n")}
                       :hide {:statusline false}
                       :theme :doom})
          (each [_ button (ipairs opts.config.center)]
            (set button.desc
                 (.. button.desc (string.rep " " (- 43 (length button.desc))))))
          (when (= vim.o.filetype :lazy)
            (vim.cmd.close)
            (vim.api.nvim_create_autocmd :User
                                         {:callback (fn []
                                                      ((. (require :lazy) :show)))
                                          :pattern :DashboardLoaded}))
          opts)}]

