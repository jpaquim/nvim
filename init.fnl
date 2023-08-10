(local lazypath (.. (vim.fn.stdpath :data) :/lazy/lazy.nvim))

(when (not (vim.loop.fs_stat lazypath))
  (vim.fn.system [:git
                  :clone
                  "--filter=blob:none"
                  "https://github.com/folke/lazy.nvim.git"
                  :--branch=stable
                  lazypath]))

(vim.opt.rtp:prepend (or vim.env.LAZY lazypath))

((. (require :lazy) :setup) {:checker {:enabled true}
                             :defaults {:lazy false :version false}
                             :install {:colorscheme [:tokyonight :habamax]}
                             :performance {:rtp {:disabled_plugins [:gzip
                                                                    :tarPlugin
                                                                    :tohtml
                                                                    :tutor
                                                                    :zipPlugin]}}
                             :spec [{:import :plugins}
                                    {:import :plugins.extras.coding.copilot}
                                    {:import :plugins.extras.dap.core}
                                    {:import :plugins.extras.dap.nlua}
                                    {:import :plugins.extras.formatting.prettier}
                                    {:import :plugins.extras.lang.json}
                                    {:import :plugins.extras.lang.tailwind}
                                    {:import :plugins.extras.lang.typescript}
                                    {:import :plugins.extras.linting.eslint}
                                    {:import :plugins.extras.ui.mini-animate}
                                    {:import :plugins.extras.ui.mini-starter}
                                    {:import :plugins.extras.util.project}
                                    {:import :plugins.extras.lang.lisp}
                                    {:import :plugins.extras.lang.glsl}]})

((. (require :config) :setup))

