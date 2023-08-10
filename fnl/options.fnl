(set vim.g.mapleader " ")

(set vim.g.maplocalleader ",")

(set vim.g.autoformat true)

(set vim.g.root_spec [:lsp [:.git :lua] :cwd])

(local opt vim.opt)

(set opt.autowrite true)

(set opt.clipboard :unnamedplus)

(set opt.completeopt "menu,menuone,noselect")

(set opt.conceallevel 3)

(set opt.confirm true)

(set opt.cursorline true)

(set opt.expandtab true)

(set opt.formatoptions :jcroqlnt)

(set opt.grepformat "%f:%l:%c:%m")

(set opt.grepprg "rg --vimgrep")

(set opt.ignorecase true)

(set opt.inccommand :nosplit)

(set opt.laststatus 3)

(set opt.list true)

(set opt.mouse :a)

(set opt.number true)

(set opt.pumblend 10)

(set opt.pumheight 10)

(set opt.relativenumber true)

(set opt.scrolloff 4)

(set opt.sessionoptions [:buffers
                         :curdir
                         :tabpages
                         :winsize
                         :help
                         :globals
                         :skiprtp])

(set opt.shiftround true)

(set opt.shiftwidth 2)

(opt.shortmess:append {:C true :I true :W true :c true})

(set opt.showmode false)

(set opt.sidescrolloff 8)

(set opt.signcolumn :yes)

(set opt.smartcase true)

(set opt.smartindent true)

(set opt.spelllang [:en])

(set opt.splitbelow true)

(set opt.splitkeep :screen)

(set opt.splitright true)

(set opt.tabstop 2)

(set opt.termguicolors true)

(set opt.timeoutlen 300)

(set opt.undofile true)

(set opt.undolevels 10000)

(set opt.updatetime 200)

(set opt.virtualedit :block)

(set opt.wildmode "longest:full,full")

(set opt.winminwidth 5)

(set opt.wrap false)

(set opt.fillchars {:diff "╱"
                    :eob " "
                    :fold " "
                    :foldclose ""
                    :foldopen ""
                    :foldsep " "})

(when (= (vim.fn.has :nvim-0.10) 1) (set opt.smoothscroll true))

(set vim.opt.foldlevel 99)

(set vim.opt.foldtext "v:lua.require'util'.ui.foldtext()")

(when (= (vim.fn.has :nvim-0.9.0) 1)
  (set vim.opt.statuscolumn "%!v:lua.require'util'.ui.statuscolumn()"))

(if (= (vim.fn.has :nvim-0.10) 1)
    (do
      (set vim.opt.foldmethod :expr)
      (set vim.opt.foldexpr "v:lua.vim.treesitter.foldexpr()"))
    (set vim.opt.foldmethod :indent))

(set vim.g.markdown_recommended_style 0)

(set opt.commentstring "// %s")

