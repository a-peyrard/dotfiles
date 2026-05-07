" Load signify's original util.vim first (provides popup_close, escape, etc.)
let s:lazy_dir = stdpath('data') .. '/lazy/vim-signify/autoload/sy/util.vim'
execute 'source' s:lazy_dir

" Override popup_create with bordered floating window via Lua
function! sy#util#popup_create(hunkdiff) abort
  call v:lua._signify_popup_create(a:hunkdiff)
  return 1
endfunction
