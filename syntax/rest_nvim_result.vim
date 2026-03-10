" rest.nvim result pane syntax with JSON body highlighting
if exists("b:current_syntax")
  finish
endif

" Include JSON syntax for the response body region
syn include @Json syntax/json.vim
unlet b:current_syntax

" Request section
syn match restNvimRequest "^### Request:.*"
syn match restNvimRequestLine "^\s*\%(GET\|POST\|PUT\|PATCH\|DELETE\|HEAD\|OPTIONS\).*$"
hi def link restNvimRequest Title
hi def link restNvimRequestLine Keyword

" Response section
syn match restNvimResponse "^--- Response ---"
syn match restNvimStatusLine "^\s*HTTP/.*$"
hi def link restNvimResponse Title
hi def link restNvimStatusLine Keyword

" Headers
syn match restNvimHeader "^[<>]\s*\S\+:.*$"
hi def link restNvimHeader Identifier

" JSON body between # @_RES and # @_END
syn region restNvimJsonBody start="^# @_RES.*$" end="^# @_END$" contains=@Json
hi def link restNvimJsonBody Normal

" Marker lines
syn match restNvimMarker "^# @_RES.*$"
syn match restNvimMarker "^# @_END$"
hi def link restNvimMarker Comment

let b:current_syntax = "rest_nvim_result"
