filetype plugin indent on
syntax enable
set bg=dark tw=80 so=3 et nohls nojs title hidden
set ignorecase smartcase

nmap <Space>bb <C-^>
nmap <Space>fb :Buffers<CR>
nmap <Space>ff :Files<CR>
nmap <Space>ft :Tags<CR>
nmap <Space>r :%s/\C\<<C-R><C-W>\>/
nmap <Space>w <C-W>
nmap Q @q
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

hi Pmenu ctermbg=236 ctermfg=15
hi DiagnosticFloatingError ctermfg=9  cterm=none
hi DiagnosticFloatingWarn  ctermfg=11 cterm=none
hi DiagnosticFloatingInfo  ctermfg=12 cterm=none
hi DiagnosticFloatingHint  ctermfg=12 cterm=none
hi DiagnosticUnderlineError ctermbg=1
hi DiagnosticUnderlineWarn  ctermbg=3
hi DiagnosticUnderlineInfo  ctermbg=4
hi DiagnosticUnderlineHint  ctermbg=4

let g:zig_fmt_autosave = 0

" LANGUAGE SERVERS

lua require'lspconfig'.hls.setup{}
lua require'lspconfig'.rust_analyzer.setup{}
lua require'lspconfig'.zls.setup{}

lua << EOF
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    signs = false,
  }
)
EOF

nmap <F2> :lua vim.diagnostic.goto_next()<CR>
nmap <F3> :lua vim.lsp.buf.hover()<CR>
nmap <Space>la :lua vim.lsp.buf.code_action()<CR>
nmap <Space>ln :lua vim.diagnostic.goto_next()<CR>
nmap <Space>lf :lua vim.lsp.buf.formatting()<CR>
