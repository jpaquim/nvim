(local Util (require :util))

(local java-filetypes [:java])

(fn extend-or-override [config custom ...]
  (if (= (type custom) :function)
      (set-forcibly! config (or (custom config ...) config)) custom
      (set-forcibly! config (vim.tbl_deep_extend :force config custom)))
  config)

[{1 :nvim-treesitter/nvim-treesitter
  :opts (fn [_ opts]
          (set opts.ensure_installed (or opts.ensure_installed {}))
          (vim.list_extend opts.ensure_installed [:java]))}
 {1 :mfussenegger/nvim-dap
  :dependencies [{1 :williamboman/mason.nvim
                  :opts (fn [_ opts]
                          (set opts.ensure_installed
                               (or opts.ensure_installed {}))
                          (vim.list_extend opts.ensure_installed
                                           [:java-test :java-debug-adapter]))}]
  :optional true}
 {1 :neovim/nvim-lspconfig
  :opts {:servers {:jdtls {}} :setup {:jdtls (fn [] true)}}}
 {1 :mfussenegger/nvim-jdtls
  :config (fn []
            (local opts (or (Util.opts :nvim-jdtls) {}))
            (local mason-registry (require :mason-registry))
            (local bundles {})
            (when (and (and opts.dap (Util.has :nvim-dap))
                       (mason-registry.is_installed :java-debug-adapter))
              (local java-dbg-pkg
                     (mason-registry.get_package :java-debug-adapter))
              (local java-dbg-path (java-dbg-pkg:get_install_path))
              (local jar-patterns
                     [(.. java-dbg-path
                          :/extension/server/com.microsoft.java.debug.plugin-*.jar)])
              (when (and opts.test (mason-registry.is_installed :java-test))
                (local java-test-pkg (mason-registry.get_package :java-test))
                (local java-test-path (java-test-pkg:get_install_path))
                (vim.list_extend jar-patterns
                                 [(.. java-test-path :/extension/server/*.jar)]))
              (each [_ jar-pattern (ipairs jar-patterns)]
                (each [_ bundle (ipairs (vim.split (vim.fn.glob jar-pattern)
                                                   "\n"))]
                  (table.insert bundles bundle))))

            (fn attach-jdtls []
              (local fname (vim.api.nvim_buf_get_name 0))
              (local config
                     (extend-or-override {:capabilities ((. (require :cmp_nvim_lsp)
                                                            :default_capabilities))
                                          :cmd (opts.full_cmd opts)
                                          :init_options {: bundles}
                                          :root_dir (opts.root_dir fname)}
                                         opts.jdtls))
              ((. (require :jdtls) :start_or_attach) config))

            (vim.api.nvim_create_autocmd :FileType
                                         {:callback attach-jdtls
                                          :pattern java-filetypes})
            (vim.api.nvim_create_autocmd :LspAttach
                                         {:callback (fn [args]
                                                      (local client
                                                             (vim.lsp.get_client_by_id args.data.client_id))
                                                      (when (and client
                                                                 (= client.name
                                                                    :jdtls))
                                                        (local wk
                                                               (require :which-key))
                                                        (wk.register {:<leader>co [(. (require :jdtls)
                                                                                      :organize_imports)
                                                                                   "Organize Imports"]
                                                                      :<leader>cx {:name :+extract}
                                                                      :<leader>cxc [(. (require :jdtls)
                                                                                       :extract_constant)
                                                                                    "Extract Constant"]
                                                                      :<leader>cxv [(. (require :jdtls)
                                                                                       :extract_variable_all)
                                                                                    "Extract Variable"]
                                                                      :gS [(. (require :jdtls.tests)
                                                                              :goto_subjects)
                                                                           "Goto Subjects"]
                                                                      :gs [(. (require :jdtls)
                                                                              :super_implementation)
                                                                           "Goto Super"]}
                                                                     {:buffer args.buf
                                                                      :mode :n})
                                                        (wk.register {:<leader>c {:name :+code}
                                                                      :<leader>cx {:name :+extract}
                                                                      :<leader>cxc ["<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>"
                                                                                    "Extract Constant"]
                                                                      :<leader>cxm ["<ESC><CMD>lua require('jdtls').extract_method(true)<CR>"
                                                                                    "Extract Method"]
                                                                      :<leader>cxv ["<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>"
                                                                                    "Extract Variable"]}
                                                                     {:buffer args.buf
                                                                      :mode :v})
                                                        (when (and (and opts.dap
                                                                        (Util.has :nvim-dap))
                                                                   (mason-registry.is_installed :java-debug-adapter))
                                                          ((. (require :jdtls)
                                                              :setup_dap) opts.dap)
                                                          ((. (require :jdtls.dap)
                                                              :setup_dap_main_class_configs))
                                                          (when (and opts.test
                                                                     (mason-registry.is_installed :java-test))
                                                            (wk.register {:<leader>t {:name :+test}
                                                                          :<leader>tT [(. (require :jdtls.dap)
                                                                                          :pick_test)
                                                                                       "Run Test"]
                                                                          :<leader>tr [(. (require :jdtls.dap)
                                                                                          :test_nearest_method)
                                                                                       "Run Nearest Test"]
                                                                          :<leader>tt [(. (require :jdtls.dap)
                                                                                          :test_class)
                                                                                       "Run All Test"]}
                                                                         {:buffer args.buf
                                                                          :mode :n})))
                                                        (when opts.on_attach
                                                          (opts.on_attach args))))})
            (attach-jdtls))
  :dependencies [:folke/which-key.nvim]
  :ft java-filetypes
  :opts (fn []
          {:cmd [:jdtls]
           :dap {:config_overrides {} :hotcodereplace :auto}
           :full_cmd (fn [opts]
                       (local fname (vim.api.nvim_buf_get_name 0))
                       (local root-dir (opts.root_dir fname))
                       (local project-name (opts.project_name root-dir))
                       (local cmd (vim.deepcopy opts.cmd))
                       (when project-name
                         (vim.list_extend cmd
                                          [:-configuration
                                           (opts.jdtls_config_dir project-name)
                                           :-data
                                           (opts.jdtls_workspace_dir project-name)]))
                       cmd)
           :jdtls_config_dir (fn [project-name]
                               (.. (vim.fn.stdpath :cache) :/jdtls/
                                   project-name :/config))
           :jdtls_workspace_dir (fn [project-name]
                                  (.. (vim.fn.stdpath :cache) :/jdtls/
                                      project-name :/workspace))
           :project_name (fn [root-dir]
                           (and root-dir (vim.fs.basename root-dir)))
           :root_dir (. (require :lspconfig.server_configurations.jdtls)
                        :default_config :root_dir)
           :test true})}]

