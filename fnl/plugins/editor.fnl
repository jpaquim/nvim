(local Util (require :util))

[{1 :nvim-neo-tree/neo-tree.nvim
  :branch :v3.x
  :cmd :Neotree
  :config (fn [_ opts]
            (fn on-move [data]
              (Util.lsp.on_rename data.source data.destination))

            (local events (require :neo-tree.events))
            (set opts.event_handlers (or opts.event_handlers {}))
            (vim.list_extend opts.event_handlers
                             [{:event events.FILE_MOVED :handler on-move}
                              {:event events.FILE_RENAMED :handler on-move}])
            ((. (require :neo-tree) :setup) opts)
            (vim.api.nvim_create_autocmd :TermClose
                                         {:callback (fn []
                                                      (when (. package.loaded
                                                               :neo-tree.sources.git_status)
                                                        ((. (require :neo-tree.sources.git_status)
                                                            :refresh))))
                                          :pattern :*lazygit}))
  :deactivate (fn [] (vim.cmd "Neotree close"))
  :init (fn []
          (when (= (vim.fn.argc (- 1)) 1)
            (local stat (vim.loop.fs_stat (vim.fn.argv 0)))
            (when (and stat (= stat.type :directory)) (require :neo-tree))))
  :keys [{1 :<leader>fe
          2 (fn []
              ((. (require :neo-tree.command) :execute) {:dir (Util.root)
                                                         :toggle true}))
          :desc "Explorer NeoTree (root dir)"}
         {1 :<leader>fE
          2 (fn []
              ((. (require :neo-tree.command) :execute) {:dir (vim.loop.cwd)
                                                         :toggle true}))
          :desc "Explorer NeoTree (cwd)"}
         {1 :<leader>e
          2 :<leader>fe
          :desc "Explorer NeoTree (root dir)"
          :remap true}
         {1 :<leader>E
          2 :<leader>fE
          :desc "Explorer NeoTree (cwd)"
          :remap true}]
  :opts {:default_component_configs {:indent {:expander_collapsed ""
                                              :expander_expanded ""
                                              :expander_highlight :NeoTreeExpander
                                              :with_expanders true}}
         :filesystem {:bind_to_cwd false
                      :follow_current_file {:enabled true}
                      :use_libuv_file_watcher true}
         :open_files_do_not_replace_types [:terminal :Trouble :qf :Outline]
         :sources [:filesystem :buffers :git_status :document_symbols]
         :window {:mappings {:<space> :none}}}}
 {1 :nvim-pack/nvim-spectre
  :cmd :Spectre
  :keys [{1 :<leader>sr
          2 (fn []
              ((. (require :spectre) :open)))
          :desc "Replace in files (Spectre)"}]
  :opts {:open_cmd "noswapfile vnew"}}
 {1 :nvim-telescope/telescope.nvim
  :cmd :Telescope
  :dependencies [{1 :nvim-telescope/telescope-fzf-native.nvim
                  :build :make
                  :config (fn []
                            (Util.on_load :telescope.nvim
                                          (fn []
                                            ((. (require :telescope)
                                                :load_extension) :fzf))))
                  :enabled (= (vim.fn.executable :make) 1)}]
  :keys [{1 "<leader>,"
          2 "<cmd>Telescope buffers show_all_buffers=true<cr>"
          :desc "Switch Buffer"}
         {1 :<leader>/ 2 (Util.telescope :live_grep) :desc "Grep (root dir)"}
         {1 "<leader>:"
          2 "<cmd>Telescope command_history<cr>"
          :desc "Command History"}
         {1 :<leader><space>
          2 (Util.telescope :files)
          :desc "Find Files (root dir)"}
         {1 :<leader>fb 2 "<cmd>Telescope buffers<cr>" :desc :Buffers}
         {1 :<leader>ff
          2 (Util.telescope :files)
          :desc "Find Files (root dir)"}
         {1 :<leader>fF
          2 (Util.telescope :files {:cwd false})
          :desc "Find Files (cwd)"}
         {1 :<leader>fr 2 "<cmd>Telescope oldfiles<cr>" :desc :Recent}
         {1 :<leader>fR
          2 (Util.telescope :oldfiles {:cwd (vim.loop.cwd)})
          :desc "Recent (cwd)"}
         {1 :<leader>gc 2 "<cmd>Telescope git_commits<CR>" :desc :commits}
         {1 :<leader>gs 2 "<cmd>Telescope git_status<CR>" :desc :status}
         {1 "<leader>s\"" 2 "<cmd>Telescope registers<cr>" :desc :Registers}
         {1 :<leader>sa
          2 "<cmd>Telescope autocommands<cr>"
          :desc "Auto Commands"}
         {1 :<leader>sb
          2 "<cmd>Telescope current_buffer_fuzzy_find<cr>"
          :desc :Buffer}
         {1 :<leader>sc
          2 "<cmd>Telescope command_history<cr>"
          :desc "Command History"}
         {1 :<leader>sC 2 "<cmd>Telescope commands<cr>" :desc :Commands}
         {1 :<leader>sd
          2 "<cmd>Telescope diagnostics bufnr=0<cr>"
          :desc "Document diagnostics"}
         {1 :<leader>sD
          2 "<cmd>Telescope diagnostics<cr>"
          :desc "Workspace diagnostics"}
         {1 :<leader>sg 2 (Util.telescope :live_grep) :desc "Grep (root dir)"}
         {1 :<leader>sG
          2 (Util.telescope :live_grep {:cwd false})
          :desc "Grep (cwd)"}
         {1 :<leader>sh 2 "<cmd>Telescope help_tags<cr>" :desc "Help Pages"}
         {1 :<leader>sH
          2 "<cmd>Telescope highlights<cr>"
          :desc "Search Highlight Groups"}
         {1 :<leader>sk 2 "<cmd>Telescope keymaps<cr>" :desc "Key Maps"}
         {1 :<leader>sM 2 "<cmd>Telescope man_pages<cr>" :desc "Man Pages"}
         {1 :<leader>sm 2 "<cmd>Telescope marks<cr>" :desc "Jump to Mark"}
         {1 :<leader>so 2 "<cmd>Telescope vim_options<cr>" :desc :Options}
         {1 :<leader>sR 2 "<cmd>Telescope resume<cr>" :desc :Resume}
         {1 :<leader>sw
          2 (Util.telescope :grep_string {:word_match :-w})
          :desc "Word (root dir)"}
         {1 :<leader>sW
          2 (Util.telescope :grep_string {:cwd false :word_match :-w})
          :desc "Word (cwd)"}
         {1 :<leader>sw
          2 (Util.telescope :grep_string)
          :desc "Selection (root dir)"
          :mode :v}
         {1 :<leader>sW
          2 (Util.telescope :grep_string {:cwd false})
          :desc "Selection (cwd)"
          :mode :v}
         {1 :<leader>uC
          2 (Util.telescope :colorscheme {:enable_preview true})
          :desc "Colorscheme with preview"}
         {1 :<leader>ss
          2 (fn []
              ((. (require :telescope.builtin) :lsp_document_symbols) {:symbols ((. (require :config)
                                                                                    :get_kind_filter))}))
          :desc "Goto Symbol"}
         {1 :<leader>sS
          2 (fn []
              ((. (require :telescope.builtin) :lsp_dynamic_workspace_symbols) {:symbols ((. (require :config)
                                                                                             :get_kind_filter))}))
          :desc "Goto Symbol (Workspace)"}]
  :opts (fn []
          (local actions (require :telescope.actions))

          (fn open-with-trouble [...]
            ((. (require :trouble.providers.telescope) :open_with_trouble) ...))

          (fn open-selected-with-trouble [...]
            ((. (require :trouble.providers.telescope)
                :open_selected_with_trouble) ...))

          (fn find-files-no-ignore []
            (local action-state (require :telescope.actions.state))
            (local line (action-state.get_current_line))
            ((Util.telescope :find_files {:default_text line :no_ignore true})))

          (fn find-files-with-hidden []
            (local action-state (require :telescope.actions.state))
            (local line (action-state.get_current_line))
            ((Util.telescope :find_files {:default_text line :hidden true})))

          {:defaults {:get_selection_window (fn []
                                              (local wins
                                                     (vim.api.nvim_list_wins))
                                              (table.insert wins 1
                                                            (vim.api.nvim_get_current_win))
                                              (each [_ win (ipairs wins)]
                                                (local buf
                                                       (vim.api.nvim_win_get_buf win))
                                                (when (= (. vim.bo buf :buftype)
                                                         "")
                                                  (lua "return win")))
                                              0)
                      :mappings {:i {:<C-Down> actions.cycle_history_next
                                     :<C-Up> actions.cycle_history_prev
                                     :<C-b> actions.preview_scrolling_up
                                     :<C-f> actions.preview_scrolling_down
                                     :<a-h> find-files-with-hidden
                                     :<a-i> find-files-no-ignore
                                     :<a-t> open-selected-with-trouble
                                     :<c-t> open-with-trouble}
                                 :n {:q actions.close}}
                      :prompt_prefix " "
                      :selection_caret " "}})
  :version false}
 {1 :folke/flash.nvim
  :event :VeryLazy
  :keys [{1 :s
          2 (fn []
              ((. (require :flash) :jump)))
          :desc :Flash
          :mode [:n :x :o]}
         {1 :S
          2 (fn []
              ((. (require :flash) :treesitter)))
          :desc "Flash Treesitter"
          :mode [:n :o :x]}
         {1 :r
          2 (fn []
              ((. (require :flash) :remote)))
          :desc "Remote Flash"
          :mode :o}
         {1 :R
          2 (fn []
              ((. (require :flash) :treesitter_search)))
          :desc "Treesitter Search"
          :mode [:o :x]}
         {1 :<c-s>
          2 (fn []
              ((. (require :flash) :toggle)))
          :desc "Toggle Flash Search"
          :mode [:c]}]
  :opts {}
  :vscode true}
 {1 :nvim-telescope/telescope.nvim
  :optional true
  :opts (fn [_ opts]
          (when (not (Util.has :flash.nvim)) (lua "return "))

          (fn flash [prompt-bufnr]
            ((. (require :flash) :jump) {:action (fn [___match___]
                                                   (local picker
                                                          ((. (require :telescope.actions.state)
                                                              :get_current_picker) prompt-bufnr))
                                                   (picker:set_selection (- (. ___match___.pos
                                                                               1)
                                                                            1)))
                                         :label {:after [0 0]}
                                         :pattern "^"
                                         :search {:exclude [(fn [win]
                                                              (not= (. vim.bo
                                                                       (vim.api.nvim_win_get_buf win)
                                                                       :filetype)
                                                                    :TelescopeResults))]
                                                  :mode :search}}))

          (set opts.defaults
               (vim.tbl_deep_extend :force (or opts.defaults {})
                                    {:mappings {:i {:<c-s> flash}
                                                :n {:s flash}}})))}
 {1 :folke/which-key.nvim
  :config (fn [_ opts] (local wk (require :which-key)) (wk.setup opts)
            (wk.register opts.defaults))
  :event :VeryLazy
  :opts {:defaults {:<leader><tab> {:name :+tabs}
                    :<leader>b {:name :+buffer}
                    :<leader>c {:name :+code}
                    :<leader>f {:name :+file/find}
                    :<leader>g {:name :+git}
                    :<leader>gh {:name :+hunks}
                    :<leader>q {:name :+quit/session}
                    :<leader>s {:name :+search}
                    :<leader>u {:name :+ui}
                    :<leader>w {:name :+windows}
                    :<leader>x {:name :+diagnostics/quickfix}
                    "[" {:name :+prev}
                    "]" {:name :+next}
                    :g {:name :+goto}
                    :gs {:name :+surround}
                    :mode [:n :v]}
         :plugins {:spelling true}}}
 {1 :lewis6991/gitsigns.nvim
  :event :LazyFile
  :opts {:on_attach (fn [buffer]
                      (local gs package.loaded.gitsigns)

                      (fn map [mode l r desc]
                        (vim.keymap.set mode l r {: buffer : desc}))

                      (map :n "]h" gs.next_hunk "Next Hunk")
                      (map :n "[h" gs.prev_hunk "Prev Hunk")
                      (map [:n :v] :<leader>ghs ":Gitsigns stage_hunk<CR>"
                           "Stage Hunk")
                      (map [:n :v] :<leader>ghr ":Gitsigns reset_hunk<CR>"
                           "Reset Hunk")
                      (map :n :<leader>ghS gs.stage_buffer "Stage Buffer")
                      (map :n :<leader>ghu gs.undo_stage_hunk "Undo Stage Hunk")
                      (map :n :<leader>ghR gs.reset_buffer "Reset Buffer")
                      (map :n :<leader>ghp gs.preview_hunk "Preview Hunk")
                      (map :n :<leader>ghb (fn [] (gs.blame_line {:full true}))
                           "Blame Line")
                      (map :n :<leader>ghd gs.diffthis "Diff This")
                      (map :n :<leader>ghD (fn [] (gs.diffthis "~"))
                           "Diff This ~")
                      (map [:o :x] :ih ":<C-U>Gitsigns select_hunk<CR>"
                           "GitSigns Select Hunk"))
         :signs {:add {:text "▎"}
                 :change {:text "▎"}
                 :changedelete {:text "▎"}
                 :delete {:text ""}
                 :topdelete {:text ""}
                 :untracked {:text "▎"}}}}
 {1 :RRethy/vim-illuminate
  :config (fn [_ opts]
            ((. (require :illuminate) :configure) opts)

            (fn map [key dir buffer]
              (vim.keymap.set :n key
                              (fn []
                                ((. (require :illuminate)
                                    (.. :goto_ dir :_reference)) false))
                              {: buffer
                               :desc (.. (: (dir:sub 1 1) :upper) (dir:sub 2)
                                         " Reference")}))

            (map "]]" :next)
            (map "[[" :prev)
            (vim.api.nvim_create_autocmd :FileType
                                         {:callback (fn []
                                                      (local buffer
                                                             (vim.api.nvim_get_current_buf))
                                                      (map "]]" :next buffer)
                                                      (map "[[" :prev buffer))}))
  :event :LazyFile
  :keys [{1 "]]" :desc "Next Reference"} {1 "[[" :desc "Prev Reference"}]
  :opts {:delay 200
         :large_file_cutoff 2000
         :large_file_overrides {:providers [:lsp]}}}
 {1 :echasnovski/mini.bufremove
  :keys [{1 :<leader>bd
          2 (fn []
              (local bd (. (require :mini.bufremove) :delete))
              (if vim.bo.modified
                  (do
                    (local choice
                           (vim.fn.confirm (: "Save changes to %q?" :format
                                              (vim.fn.bufname))
                                           "&Yes\n&No\n&Cancel"))
                    (if (= choice 1) (do
                                       (vim.cmd.write)
                                       (bd 0))
                        (= choice 2) (bd 0 true))) (bd 0)))
          :desc "Delete Buffer"}
         {1 :<leader>bD
          2 (fn []
              ((. (require :mini.bufremove) :delete) 0 true))
          :desc "Delete Buffer (Force)"}]}
 {1 :folke/trouble.nvim
  :cmd [:TroubleToggle :Trouble]
  :keys [{1 :<leader>xx
          2 "<cmd>TroubleToggle document_diagnostics<cr>"
          :desc "Document Diagnostics (Trouble)"}
         {1 :<leader>xX
          2 "<cmd>TroubleToggle workspace_diagnostics<cr>"
          :desc "Workspace Diagnostics (Trouble)"}
         {1 :<leader>xL
          2 "<cmd>TroubleToggle loclist<cr>"
          :desc "Location List (Trouble)"}
         {1 :<leader>xQ
          2 "<cmd>TroubleToggle quickfix<cr>"
          :desc "Quickfix List (Trouble)"}
         {1 "[q"
          2 (fn []
              (if ((. (require :trouble) :is_open))
                  ((. (require :trouble) :previous) {:jump true
                                                     :skip_groups true})
                  (do
                    (local (ok err) (pcall vim.cmd.cprev))
                    (when (not ok) (vim.notify err vim.log.levels.ERROR)))))
          :desc "Previous trouble/quickfix item"}
         {1 "]q"
          2 (fn []
              (if ((. (require :trouble) :is_open))
                  ((. (require :trouble) :next) {:jump true :skip_groups true})
                  (do
                    (local (ok err) (pcall vim.cmd.cnext))
                    (when (not ok) (vim.notify err vim.log.levels.ERROR)))))
          :desc "Next trouble/quickfix item"}]
  :opts {:use_diagnostic_signs true}}
 {1 :folke/todo-comments.nvim
  :cmd [:TodoTrouble :TodoTelescope]
  :config true
  :event :LazyFile
  :keys [{1 "]t"
          2 (fn []
              ((. (require :todo-comments) :jump_next)))
          :desc "Next todo comment"}
         {1 "[t"
          2 (fn []
              ((. (require :todo-comments) :jump_prev)))
          :desc "Previous todo comment"}
         {1 :<leader>xt 2 :<cmd>TodoTrouble<cr> :desc "Todo (Trouble)"}
         {1 :<leader>xT
          2 "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>"
          :desc "Todo/Fix/Fixme (Trouble)"}
         {1 :<leader>st 2 :<cmd>TodoTelescope<cr> :desc :Todo}
         {1 :<leader>sT
          2 "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>"
          :desc :Todo/Fix/Fixme}]}]

