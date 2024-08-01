# My python nvim configuration

### Installation
```sh
 curl -s https://raw.githubusercontent.com/iklobato/iklobato-nvim-config-python/install.sh | bash
 ```


## Neovim Configuration Features
Plugin Name         | Feature                | Description                                 | Shortcut | Mnemonic
--------------------|------------------------|---------------------------------------------|----------|---------
General Keymaps     | Save and quit           | Save the current file and quit Vim          | wq       | "W"rite and "Q"uit
General Keymaps     | Quit without saving    | Quit Vim without saving                     | qq       | "Q"uit without saving
General Keymaps     | Save                   | Save the current file                       | ww       | "W"rite "W"rite
General Keymaps     | Open URL under cursor  | Open the URL under the cursor               | gx       | "G"oto e"X"ternal URL
Split Window        | Split window vertically| Split the window vertically                 | sv       | "S"plit "V"ertically
Split Window        | Split window horizontally| Split the window horizontally             | sh       | "S"plit "H"orizontally
Split Window        | Equal width splits     | Make split windows equal width              | se       | "S"ame "E"qual width
Split Window        | Close split window     | Close the current split window              | sx       | "S"plit "X"terminate
Split Window        | Shorten window height  | Make the split window height shorter        | sj       | "S"hort "J"ump height
Split Window        | Increase window height | Make the split window height taller         | sk       | "S"tretch "K"eep taller
Split Window        | Increase window width  | Make the split window width bigger          | sl       | "S"tretch "L"onger width
Split Window        | Decrease window width  | Make the split window width smaller         | sh       | "S"hrink width
Tab Management      | Open new tab           | Open a new tab                              | to       | "T"ab "O"pen
Tab Management      | Close a tab            | Close the current tab                       | tx       | "T"ab e"X"it
Tab Management      | Next tab               | Switch to the next tab                      | tn       | "T"ab "N"ext
Tab Management      | Previous tab           | Switch to the previous tab                  | tp       | "T"ab "P"revious
Diff                | Put diff               | Put diff from current to other              | cc       | "C"ompare "C"hanges
Diff                | Get diff from left     | Get diff from the left (local)              | cj       | "C"ompare "J"ump left
Diff                | Get diff from right    | Get diff from the right (remote)            | ck       | "C"ompare "K"eep right
Diff                | Next diff hunk         | Move to the next diff hunk                  | cn       | "C"ompare "N"ext hunk
Diff                | Previous diff hunk     | Move to the previous diff hunk              | cp       | "C"ompare "P"revious hunk
Quickfix            | Open quickfix list     | Open the quickfix list                      | qo       | "Q"uickfix "O"pen
Quickfix            | Jump to first item     | Jump to the first item in the quickfix list | qf       | "Q"uickfix "F"irst
Quickfix            | Jump to next item      | Jump to the next item in the quickfix list  | qn       | "Q"uickfix "N"ext
Quickfix            | Jump to previous item  | Jump to the previous item in the quickfix list| qp      | "Q"uickfix "P"revious
Quickfix            | Jump to last item      | Jump to the last item in the quickfix list  | ql       | "Q"uickfix "L"ast
Quickfix            | Close quickfix list    | Close the quickfix list                     | qc       | "Q"uickfix "C"lose
Vim-maximizer       | Toggle maximize tab    | Toggle maximizing the current tab           | sm       | "S"ize "M"aximize
Nvim-tree           | Toggle file explorer   | Toggle the file explorer                    | ee       | "E"xplorer "E"nable
Nvim-tree           | Focus file explorer    | Focus on the file explorer                  | er       | "E"xplorer "R"e-focus
Nvim-tree           | Find file in explorer  | Find the file in the file explorer           | ef       | "E"xplorer "F"ind
Telescope           | Find files             | Find files using Telescope                  | ff       | "F"ind "F"iles
Telescope           | Live grep              | Search text in files using Telescope        | fg       | "F"ind "G"rep
Telescope           | Buffers                | List open buffers using Telescope           | fb       | "F"ind "B"uffers
Telescope           | Help tags              | Search help tags using Telescope            | fh       | "F"ind "H"elp tags
Telescope           | Current buffer fuzzy find| Fuzzy find text in the current buffer     | fs       | "F"uzzy "S"earch
Telescope           | LSP document symbols   | List LSP document symbols using Telescope   | fo       | "F"ind "O"bjects
Telescope           | LSP incoming calls     | List LSP incoming calls using Telescope     | fi       | "F"ind "I"ncoming calls
Telescope           | Treesitter methods     | Find Treesitter methods using Telescope     | fm       | "F"ind "M"ethods
Git-blame           | Toggle git blame        | Toggle Git blame view                       | gb       | "G"it "B"lame
Vim REST Console    | Run REST query         | Run a REST query using Vim REST Console     | xr       | "X"ecute "R"EST query
LSP                 | Hover                  | Show hover information from LSP             | gg       | "G"et "G"eneral hover
LSP                 | Go to definition       | Go to LSP definition                        | gd       | "G"o to "D"efinition
LSP                 | Go to declaration      | Go to LSP declaration                       | gD       | "G"o to "D"eclaration
LSP                 | Go to implementation   | Go to LSP implementation                    | gi       | "G"o to "I"mplementation
LSP                 | Go to type definition  | Go to LSP type definition                   | gt       | "G"o to "T"ype definition
LSP                 | Go to references       | Go to LSP references                        | gr       | "G"o to "R"eferences
LSP                 | Signature help         | Show LSP signature help                     | gs       | "G"et "S"ignature help
LSP                 | Rename                 | Rename symbol using LSP                     | rr       | "R"e"R"ename
LSP                 | Format                 | Format code using LSP                       | gf       | "G"o "F"ormat
LSP                 | Code action            | Perform LSP code action                     | ga       | "G"o "A"ction
LSP                 | Open diagnostics       | Open diagnostic float window                | gl       | "G"et "L"ast diagnostics
LSP                 | Go to previous diagnostic| Go to previous diagnostic                   | gp       | "G"o "P"revious diagnostic
LSP                 | Go to next diagnostic  | Go to next diagnostic                       | gn       | "G"o "N"ext diagnostic
LSP                 | Document symbols       | Show document symbols using LSP             | tr       | "T"ag "R"eference
LSP                 | Autocomplete           | Trigger autocomplete using LSP              | <C-Space>| "C"trl "Space"
Debugging           | Toggle breakpoint      | Toggle a breakpoint in debugging            | bb       | "B"reakpoint "B"oth on/off
Debugging           | Set conditional breakpoint| Set a conditional breakpoint in debugging | bc       | "B"reakpoint "C"onditional
Debugging           | Set log point          | Set a log point in debugging                | bl       | "B"reakpoint "L"og
Debugging           | Clear breakpoints      | Clear all breakpoints                       | br       | "B"reakpoint "R"emove
Debugging           | List breakpoints       | List all breakpoints                        | ba       | "B"reakpoints "A"ll
Debugging           | Continue debugging     | Continue debugging                          | dc       | "D"ebug "C"ontinue
Debugging           | Step over              | Step over in debugging                      | dj       | "D"ebug "J"ump over
Debugging           | Step into              | Step into in debugging                      | dk       | "D"ebug "K"eep in
Debugging           | Step out               | Step out in debugging                       | do       | "D"ebug "O"ut
Debugging           | Disconnect debugging   | Disconnect from the debugger and close UI   | dd       | "D"ebug "D"isconnect
Debugging           | Terminate debugging    | Terminate the debugger and close UI         | dt       | "D"ebug "T"erminate
Debugging           | Toggle REPL            | Toggle the REPL console                     | dr       | "D"ebug "R"epl
Debugging           | Run last debug session | Run the last debug session                  | dl       | "D"ebug "L"ast
Debugging           | Hover widgets          | Hover over debugging widgets                | di       | "D"ebug "I"nfo
Debugging           | Show scopes            | Show scopes in a centered float             | d?       | "D"ebug "?"scopes
Debugging           | List debug frames      | List debug frames using Telescope           | df       | "D"ebug "F"rames
Debugging           | List debug commands    | List debug commands using Telescope         | dh       | "D"ebug "H"elp commands
Debugging           | List diagnostics       | List diagnostics using Telescope            | de       | "D"ebug "E"rrors
