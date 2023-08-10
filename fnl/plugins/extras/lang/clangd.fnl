[{1 :nvim-treesitter/nvim-treesitter
  :opts (fn [_ opts]
          (when (= (type opts.ensure_installed) :table)
            (vim.list_extend opts.ensure_installed [:c :cpp])))}
 {1 :p00f/clangd_extensions.nvim
  :config (fn [])
  :lazy true
  :opts {:ast {:kind_icons {:Compound ""
                            :PackExpansion ""
                            :Recovery ""
                            :TemplateParamObject ""
                            :TemplateTemplateParm ""
                            :TemplateTypeParm ""
                            :TranslationUnit ""}
               :role_icons {:declaration ""
                            :expression ""
                            :specifier ""
                            :statement ""
                            "template argument" ""
                            :type ""}}
         :inlay_hints {:inline false}}}
 {1 :neovim/nvim-lspconfig
  :opts {:servers {:clangd {:capabilities {:offsetEncoding [:utf-16]}
                            :cmd [:clangd
                                  :--background-index
                                  :--clang-tidy
                                  :--header-insertion=iwyu
                                  :--completion-style=detailed
                                  :--function-arg-placeholders
                                  :--fallback-style=llvm]
                            :init_options {:clangdFileStatus true
                                           :completeUnimported true
                                           :usePlaceholders true}
                            :keys [{1 :<leader>cR
                                    2 :<cmd>ClangdSwitchSourceHeader<cr>
                                    :desc "Switch Source/Header (C/C++)"}]
                            :root_dir (fn [fname]
                                        (or (or (((. (require :lspconfig.util)
                                                     :root_pattern) :Makefile
                                                                                                                                                   :configure.ac
                                                                                                                                                   :configure.in
                                                                                                                                                   :config.h.in
                                                                                                                                                   :meson.build
                                                                                                                                                   :meson_options.txt
                                                                                                                                                   :build.ninja) fname)
                                                (((. (require :lspconfig.util)
                                                     :root_pattern) :compile_commands.json
                                                                                                                                                   :compile_flags.txt) fname))
                                            ((. (require :lspconfig.util)
                                                :find_git_ancestor) fname)))}}
         :setup {:clangd (fn [_ opts]
                           (local clangd-ext-opts
                                  ((. (require :util) :opts) :clangd_extensions.nvim))
                           ((. (require :clangd_extensions) :setup) (vim.tbl_deep_extend :force
                                                                                         (or clangd-ext-opts
                                                                                             {})
                                                                                         {:server opts}))
                           false)}}}
 {1 :nvim-cmp
  :opts (fn [_ opts]
          (table.insert opts.sorting.comparators 1
                        (require :clangd_extensions.cmp_scores)))}
 {1 :mfussenegger/nvim-dap
  :dependencies {1 :williamboman/mason.nvim
                 :optional true
                 :opts (fn [_ opts]
                         (when (= (type opts.ensure_installed) :table)
                           (vim.list_extend opts.ensure_installed [:codelldb])))}
  :optional true
  :opts (fn []
          (local dap (require :dap))
          (when (not (. dap.adapters :codelldb))
            (tset (. (require :dap) :adapters) :codelldb
                  {:executable {:args [:--port "${port}"] :command :codelldb}
                   :host :localhost
                   :port "${port}"
                   :type :server}))
          (each [_ lang (ipairs [:c :cpp])]
            (tset dap.configurations lang
                  [{:cwd "${workspaceFolder}"
                    :name "Launch file"
                    :program (fn []
                               (vim.fn.input "Path to executable: "
                                             (.. (vim.fn.getcwd) "/") :file))
                    :request :launch
                    :type :codelldb}
                   {:cwd "${workspaceFolder}"
                    :name "Attach to process"
                    :processId (. (require :dap.utils) :pick_process)
                    :request :attach
                    :type :codelldb}])))}]

