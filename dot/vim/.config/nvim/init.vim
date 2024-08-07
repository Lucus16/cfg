set notermguicolors
colorscheme vim
filetype plugin indent on
syntax enable
set bg=dark tw=80 so=3 et nohls nojs title hidden
set ignorecase smartcase
set clipboard+=unnamedplus " Use system clipboard
set cino=:0

let hs_allow_hash_operator = 1

nmap <Space>bb <C-^>
nmap <Space>fb :Buffers<CR>
nmap <Space>ff :Files<CR>
nmap <Space>ft :Tags<CR>
nmap <Space>r :%s/\C\<<C-R><C-W>\>/
nmap <Space>w <C-W>
nmap j jzz
nmap k kzz

vmap <Space>r y:%s/\C\V<C-R>0/

au FileType bash        setlocal sts=2 ts=2 sw=2 et
au FileType cabal       setlocal sts=2 ts=2 sw=2 et
au FileType go          setlocal sts=4 ts=4 sw=4 noet
au FileType haskell     setlocal sts=2 ts=2 sw=2 et
au FileType html        setlocal sts=2 ts=2 sw=2 et
au FileType java        setlocal sts=4 ts=4 sw=4 et
au FileType javascript  setlocal sts=4 ts=4 sw=4 et
au FileType json        setlocal sts=2 ts=2 sw=2 et
au FileType purescript  setlocal sts=2 ts=2 sw=2 et
au FileType sh          setlocal sts=2 ts=2 sw=2 et
au FileType vim         setlocal sts=2 ts=2 sw=2 et
au FileType yaml        setlocal sts=2 ts=2 sw=2 et

au FileType haskell     au BufWritePre <buffer> lua vim.lsp.buf.format()

hi Pmenu ctermbg=236 ctermfg=15
hi DiagnosticFloatingError ctermfg=9  cterm=none
hi DiagnosticFloatingWarn  ctermfg=11 cterm=none
hi DiagnosticFloatingInfo  ctermfg=12 cterm=none
hi DiagnosticFloatingHint  ctermfg=12 cterm=none
hi DiagnosticUnderlineError ctermbg=1
hi DiagnosticUnderlineWarn  ctermbg=3
hi DiagnosticUnderlineInfo  ctermbg=4
hi DiagnosticUnderlineHint  ctermbg=4
hi DiffAdd    ctermbg=22
hi DiffDelete ctermbg=88

hi link nixInterpolationParam nixInterpolationParam
hi link nixInterpolationDelimiter PreProc

let g:zig_fmt_autosave = 0

nmap <F2> :lua vim.diagnostic.goto_next()<CR>
nmap <F3> :lua vim.lsp.buf.hover()<CR>
nmap <Space>la :lua vim.lsp.buf.code_action()<CR>
nmap <Space>ln :lua vim.diagnostic.goto_next()<CR>
nmap <Space>lf :lua vim.lsp.buf.format()<CR>
nmap <Space>lr :LspRestart<CR>

" LANGUAGE SERVERS

lua << EOF

require'lspconfig'.gopls.setup{}
require'lspconfig'.hls.setup{
  settings = {
    haskell = {
      formattingProvider = "fourmolu",
      plugin = {
        stan = {
          globalOn = false,
        },
      },
    },
  },
}
require'lspconfig'.rust_analyzer.setup{}
require'lspconfig'.zls.setup{}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    signs = false,
  }
)

EOF
