set nu
colo desert
" Enable syntax highlighting
syntax enable
au BufRead,BufNewFile *[^.] set filetype=vera
"au BufRead,BufNewFile *.vimrc set filetype=vim
au BufRead,BufNewFile *.vimrc set filetype=vera
au bufread,bufnewfile *.gvimrc set filetype=vera
au bufread,bufnewfile *.sv set filetype=vera
au bufread,bufnewfile *.svh set filetype=vera
au bufread,bufnewfile *.log set filetype=vera
au bufread,bufnewfile *.txt set filetype=vera
au bufread,bufnewfile *.v set filetype=verilogams
au bufread,bufnewfile *.c set filetype=c
au bufread,bufnewfile *.cpp set filetype=cpp
au bufread,bufnewfile *.asm set filetype=asm
au bufread,bufnewfile *.pl set filetype=perl
au bufread,bufnewfile *.py set filetype=python
au bufread,bufnewfile *.bat set filetype=sh

colorscheme desert 
set background=dark
set gfn=Consolas:h14

noremap <c-s> :w!<cr>
noremap <c-x> :q!<cr>
noremap <c-b> :set syntax=vera<cr>

let mapleader = "," " map leader to comma
let g:mapleader = ","

set autoindent
set tabpagemax=100

"opens a new tab with the current buffers path
" super useful when editting files within the current directory
"map <leader>te :tabe <c-r>=expand("%:h")<c-r>/
map <leader>te :tabe %:p:h
map <leader>ve :vs %:p:h
map <leader>se :sp %:p:h

"Turn backups off
set nobackup
set nowb
set noswapfile

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
" Remember info about open buffers on close
set viminfo^=%

" Always show the status line
set laststatus=2

" Format the status line
"set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l

" Set to auto read when a file is changed from the outside
set autoread

"Always show current position
set ruler
" Height of the command bar
set cmdheight=2

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Show matching brackets when text indicator is over them
set showmatch

" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

set clipboard=unnamed

map <leader>h :noh<CR>
set tabstop=2
set shiftwidth=2

augroup remember_folds
   autocmd!
   autocmd BufWinLeave * mkview
   autocmd BufWinEnter * silent! loadview
 augroup END
