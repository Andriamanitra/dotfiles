set number
set tabstop=4
set shiftwidth=4
colorscheme afterglow

set statusline=%f\ %m%y%r%w%=line\ %l/%L\ \ col\ %2.c\ 

" move to first non-whitespace with å
nnoremap å ^

" move lines up/down with Alt+arrows
nnoremap <A-k>    :m .-2<CR>
nnoremap <A-j>    :m .+1<CR>
nnoremap <A-Up>   :m .-2<CR>
nnoremap <A-Down> :m .+1<CR>
inoremap <A-Up>   <Esc>:m .-2<CR>a
inoremap <A-Down> <Esc>:m .+1<CR>a

" Ctrl+Q to quit without saving changes
inoremap <C-q> <esc>:q!<cr>
nnoremap <C-q> :q!<cr>

" Ctrl+S to save
inoremap <C-s> <esc>:w<cr>a
nnoremap <C-s> :w<cr>

" Ctrl-E to open command prompt
inoremap <C-e> <esc>:
nnoremap <C-e> :

" helper function to keep cursor position when indenting
func! Indent(ind)
  if &sol
    set nostartofline
  endif
  " don't do any weird shit (cursor was jumping to previous line)
  " if trying to dedent a line that isn't even indented
  if !a:ind && match(getline('.'),'\S') < 1
    " jump to beginning of the line
    norm! _
    return
  endif
  let vcol = virtcol('.')
  if a:ind
    norm! >>
    exe "norm!". (vcol + shiftwidth()) . '|'
  else
    norm! <<
    exe "norm!". (vcol - shiftwidth()) . '|'
  endif
endfunc

" keep cursor position when indenting
nnoremap >> :call Indent(1)<CR>
nnoremap << :call Indent(0)<CR>

" indent with tab in normal mode
nnoremap <Tab> :call Indent(1)<CR>

" dedent with Shift-tab
nnoremap <S-Tab> :call Indent(0)<CR>
inoremap <S-Tab> <Esc>:call Indent(0)<CR>I

