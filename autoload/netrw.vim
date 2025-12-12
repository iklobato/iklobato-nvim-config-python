" Stub netrw functions to prevent errors when netrw is disabled
" This prevents errors from VimEnter autocommands that try to call netrw functions
function! netrw#LocalBrowseCheck(...)
  " Stub function - do nothing since netrw is disabled
  " Accept variable arguments to prevent "too many arguments" errors
endfunction






