" HTTP/REST file syntax highlighting
" Basic syntax highlighting for .http and .rest files

if exists("b:current_syntax")
  finish
endif

syn case ignore

" HTTP Methods
syn match httpMethod "^\s*\zs\(GET\|POST\|PUT\|PATCH\|DELETE\|HEAD\|OPTIONS\|CONNECT\|TRACE\)"
syn match httpMethod "\<\(GET\|POST\|PUT\|PATCH\|DELETE\|HEAD\|OPTIONS\|CONNECT\|TRACE\)\s"

" URLs
syn match httpUrl "https\?://[^[:space:]]\+"
syn match httpUrl "\<[a-zA-Z][a-zA-Z0-9+.-]*://[^[:space:]]\+"

" Headers
syn match httpHeader "^[A-Za-z0-9_-]\+:"
syn match httpHeader "^[A-Za-z0-9_-]\+:\s"

" Variables - using character classes to avoid regex issues
syn match httpVariable "{{[^}]\+}}"
syn match httpVariable "@[a-zA-Z_][a-zA-Z0-9_]*"

" Comments
syn match httpComment "^\s*#.*$"
syn match httpComment "//.*$"

" Separators
syn match httpSeparator "^###\+.*$"
syn match httpSeparator "^---.*$"

" JSON in body
syn region httpJsonBody start="{" end="}" fold contained
syn region httpJsonBody start="\[" end="\]" fold contained

" Strings
syn region httpString start=+"+ skip=+\\"+ end=+"+ contained
syn region httpString start=+'+ skip=+\\'+ end=+'+ contained

" Numbers
syn match httpNumber "\<\d\+\>"

" Status codes
syn match httpStatus "\<\d\{3}\>"

" Highlight groups
hi def link httpMethod Statement
hi def link httpUrl Underlined
hi def link httpHeader Type
hi def link httpVariable Identifier
hi def link httpComment Comment
hi def link httpSeparator PreProc
hi def link httpString String
hi def link httpNumber Number
hi def link httpStatus Constant
hi def link httpJsonBody String

let b:current_syntax = "http"
