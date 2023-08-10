[{1 :hrsh7th/nvim-cmp
  :dependencies [{1 :Saecki/crates.nvim
                  :event ["BufRead Cargo.toml"]
                  :opts {:src {:cmp {:enabled true}}}}]
  :opts (fn [_ opts]
          (local cmp (require :cmp))
          (set opts.sources
               (cmp.config.sources (vim.list_extend opts.sources
                                                    [{:name :crates}]))))}
 {1 :nvim-treesitter/nvim-treesitter
  :opts (fn [_ opts]
          (when (= (type opts.ensure_installed) :table)
            (vim.list_extend opts.ensure_installed [:ron :rust :toml])))}
 {1 :williamboman/mason.nvim
  :optional true
  :opts (fn [_ opts]
          (when (= (type opts.ensure_installed) :table)
            (vim.list_extend opts.ensure_installed [:codelldb])))}
 {1 :simrat39/rust-tools.nvim
  :config (fn [])
  :lazy true
  :opts (fn []
          (local (ok mason-registry) (pcall require :mason-registry))
          (var adapter nil)
          (when ok
            (local codelldb (mason-registry.get_package :codelldb))
            (local extension-path (.. (codelldb:get_install_path) :/extension/))
            (local codelldb-path (.. extension-path :adapter/codelldb))
            (var liblldb-path "")
            (if (: (. (vim.loop.os_uname) :sysname) :find :Windows)
                (set liblldb-path (.. extension-path "lldb\\bin\\liblldb.dll"))
                (= (vim.fn.has :mac) 1)
                (set liblldb-path (.. extension-path :lldb/lib/liblldb.dylib))
                (set liblldb-path (.. extension-path :lldb/lib/liblldb.so)))
            (set adapter
                 ((. (require :rust-tools.dap) :get_codelldb_adapter) codelldb-path
                                                                      liblldb-path)))
          {:dap {: adapter}
           :tools {:on_initialized (fn []
                                     (vim.cmd "                  augroup RustLSP
                    autocmd CursorHold                      *.rs silent! lua vim.lsp.buf.document_highlight()
                    autocmd CursorMoved,InsertEnter         *.rs silent! lua vim.lsp.buf.clear_references()
                    autocmd BufEnter,CursorHold,InsertLeave *.rs silent! lua vim.lsp.codelens.refresh()
                  augroup END
                "))}})}
 {1 :neovim/nvim-lspconfig
  :opts {:servers {:rust_analyzer {:keys [{1 :K
                                           2 :<cmd>RustHoverActions<cr>
                                           :desc "Hover Actions (Rust)"}
                                          {1 :<leader>cR
                                           2 :<cmd>RustCodeAction<cr>
                                           :desc "Code Action (Rust)"}
                                          {1 :<leader>dr
                                           2 :<cmd>RustDebuggables<cr>
                                           :desc "Run Debuggables (Rust)"}]
                                   :settings {:rust-analyzer {:cargo {:allFeatures true
                                                                      :loadOutDirsFromCheck true
                                                                      :runBuildScripts true}
                                                              :checkOnSave {:allFeatures true
                                                                            :command :clippy
                                                                            :extraArgs [:--no-deps]}
                                                              :procMacro {:enable true
                                                                          :ignored {:async-recursion [:async_recursion]
                                                                                    :async-trait [:async_trait]
                                                                                    :napi-derive [:napi]}}}}}
                   :taplo {:keys [{1 :K
                                   2 (fn []
                                       (if (and (= (vim.fn.expand "%:t")
                                                   :Cargo.toml)
                                                ((. (require :crates)
                                                    :popup_available)))
                                           ((. (require :crates) :show_popup))
                                           (vim.lsp.buf.hover)))
                                   :desc "Show Crate Documentation"}]}}
         :setup {:rust_analyzer (fn [_ opts]
                                  (local rust-tools-opts
                                         ((. (require :util) :opts) :rust-tools.nvim))
                                  ((. (require :rust-tools) :setup) (vim.tbl_deep_extend :force
                                                                                         (or rust-tools-opts
                                                                                             {})
                                                                                         {:server opts}))
                                  true)}}}
 {1 :nvim-neotest/neotest
  :dependencies [:rouge8/neotest-rust]
  :optional true
  :opts {:adapters {:neotest-rust {}}}}]

