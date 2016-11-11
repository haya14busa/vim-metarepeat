" vim-metarepeat provides an operator (like) mapping which runs dot repeat for
" every occurence matched by last pattern (@/) in range (specified by motion or
" textobject).
"
" vim-metarepeat is inspired by 'Occurrence modifier, preset-occurrence,
" persistence-selection' feature
" http://qiita.com/t9md/items/0bc7eaff726d099943eb#occurrence-modifier-preset-occurrence-persistence-selection
"
" But it's not a port of these feature. In similar to vim-mode-plus terms,
" vim-metarepeat provides 'preset-operation-for-occurence' feature (it's just
" a operator + 'gn') and provides a way to apply the operation for each
" occurences in textobject.
"
" TODO:
" - highlight changed text to make changed texts clear for users?

nnoremap <expr> <Plug>(metarepeat) <SID>metarepeat()
xnoremap <Plug>(metarepeat) <Esc>:<C-u>call <SID>setview() <bar> call <SID>selected()<CR>

let s:saveview = {}

function! s:setview() abort
  let s:saveview = winsaveview()
endfunction

" s:metarepeat() is expected to be called with <expr> mapping.
" It registers CursorMoved event and returns 'v'.
" By using 'v' (starting visual mode) and exiting visual mode with first
" CursorMoved, it emulates 'operator' behavior without breaking dot repeat.
" (g@ breaks dot repeat)
function! s:metarepeat() abort
  augroup metarepeat-move-once
    autocmd!
    autocmd CursorMoved * call s:hook_after_move()
  augroup END
  call s:setview()
  return 'v'
endfunction

function! s:hook_after_move() abort
  autocmd! metarepeat-move-once
  execute 'normal!' "\<Esc>"
  call s:selected()
endfunction

" s:selected is expected to be called in normal mode and target has been
" selected.
function! s:selected() abort
  call s:metaoperate(getpos("'<"), getpos("'>"), @/)
endfunction

" s:metaoperate() execute dot repeat for every pattern occurence between start
" and end position.
" start: [bufnum, lnum, col, off]
" end: [bufnum, lnum, col, off]
" pattern: string
function! s:metaoperate(start, end, pattern) abort
  call setpos('.', a:start)
  let first = v:true
  let endline = a:end[1]
  let endcol = a:end[2]
  let stopline = endline + 1
  while v:true
    let flag = first ? 'c' : ''
    " use /<CR> instead of seachpos() to support {offset}. See :h search-offset
    execute 'normal!' "/\<CR>"
    let [_, lnum, col, _] = getpos('.')
    if (lnum ==# 0 && col ==# 0) || lnum > endline || (lnum ==# endline && col > endcol)
      break
    endif
    normal! .
    let first = v:false
  endwhile
  if s:saveview !=# {}
    call winrestview(s:saveview)
    let s:saveview = {}
  endif
endfunction

" ---
" support multiple preset-occurrence like feature.

nnoremap <silent> <Plug>(metarepeat-preset-occurence) :<C-u>call <SID>append_preset_occurence() <bar> set hlsearch<CR>

function! s:cword() abort
  return '\V\<' . escape(expand('<cword>'), '\') . '\>'
endfunction

function! s:append_preset_occurence() abort
  let re = s:cword()
  if has_key(b:, 'metarepeat_changedtick') && b:metarepeat_changedtick ==# b:changedtick
    " append
    let @/ = @/ . '\V\|' . re
  else
    " new
    let @/ = re
    let b:metarepeat_changedtick = b:changedtick
  endif
endfunction

" ---

if get(g:, 'meterepeat#default_mapping', 1)
  map g. <Plug>(metarepeat)
  nmap go <Plug>(metarepeat-preset-occurence)
endif
