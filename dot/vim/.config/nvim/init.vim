filetype plugin indent on
syntax enable
set bg=dark tw=100 so=3 et nohls nojs title hidden
set ignorecase smartcase

nmap j jzz
nmap k kzz
nmap Q @q
nmap <Space>fb :Buffers<CR>
nmap <Space>ft :Tags<CR>
nmap <Space>ff :Files<CR>
nmap <Space>bb <C-^>
nmap <Space>r :%s/\C\<<C-R><C-W>\>/
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
