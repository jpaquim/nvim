{1 :wookayin/semshi
 :build ":UpdateRemotePlugins"
 :ft :python
 :init (fn []
         (tset vim.g "semshi#error_sign" false)
         (tset vim.g "semshi#simplify_markup" false)
         (tset vim.g "semshi#mark_selected_nodes" false)
         (tset vim.g "semshi#update_delay_factor" 0.001)
         (vim.api.nvim_create_autocmd [:VimEnter :ColorScheme]
                                      {:callback (fn []
                                                   (vim.cmd "            highlight! semshiGlobal gui=italic
            highlight! semshiImported gui=bold
            highlight! link semshiParameter @lsp.type.parameter
            highlight! link semshiParameterUnused DiagnosticUnnecessary
            highlight! link semshiBuiltin @function.builtin
            highlight! link semshiAttribute @attribute
            highlight! link semshiSelf @lsp.type.selfKeyword
            highlight! link semshiUnresolved @lsp.type.unresolvedReference
            "))
                                       :group (vim.api.nvim_create_augroup :SemanticHighlight
                                                                           {})}))}

