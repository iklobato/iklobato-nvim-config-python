# My python nvim configuration

### Installation
```sh
 curl -s https://raw.githubusercontent.com/iklobato/iklobato-nvim-config-python/install.sh | bash
 ```


## Neovim Configuration Features

Plugin Name         | Feature                | Description                                 | Shortcut
--------------------|------------------------|---------------------------------------------|---------
General Keymaps     | Save and quit           | Save the current file and quit Vim          | wq
General Keymaps     | Quit without saving    | Quit Vim without saving                     | qq
General Keymaps     | Save                   | Save the current file                       | ww
General Keymaps     | Open URL under cursor  | Open the URL under the cursor               | gx
Split Window        | Split window vertically| Split the window vertically                 | sv
Split Window        | Split window horizontally| Split the window horizontally             | sh
Split Window        | Equal width splits     | Make split windows equal width              | se
Split Window        | Close split window     | Close the current split window              | sx
Split Window        | Shorten window height  | Make the split window height shorter        | sj
Split Window        | Increase window height | Make the split window height taller         | sk
Split Window        | Increase window width  | Make the split window width bigger          | sl
Split Window        | Decrease window width  | Make the split window width smaller         | sh
Tab Management      | Open new tab           | Open a new tab                              | to
Tab Management      | Close a tab            | Close the current tab                       | tx
Tab Management      | Next tab               | Switch to the next tab                      | tn
Tab Management      | Previous tab           | Switch to the previous tab                  | tp
Diff                | Put diff               | Put diff from current to other              | cc
Diff                | Get diff from left     | Get diff from the left (local)              | cj
Diff                | Get diff from right    | Get diff from the right (remote)            | ck
Diff                | Next diff hunk         | Move to the next diff hunk                  | cn
Diff                | Previous diff hunk     | Move to the previous diff hunk              | cp
Quickfix            | Open quickfix list     | Open the quickfix list                      | qo
Quickfix            | Jump to first item     | Jump to the first item in the quickfix list | qf
Quickfix            | Jump to next item      | Jump to the next item in the quickfix list  | qn
Quickfix            | Jump to previous item  | Jump to the previous item in the quickfix list| qp
Quickfix            | Jump to last item      | Jump to the last item in the quickfix list  | ql
Quickfix            | Close quickfix list    | Close the quickfix list                     | qc
Vim-maximizer       | Toggle maximize tab    | Toggle maximizing the current tab           | sm
Nvim-tree           | Toggle file explorer   | Toggle the file explorer                    | ee
Nvim-tree           | Focus file explorer    | Focus on the file explorer                  | er
Nvim-tree           | Find file in explorer  | Find the file in the file explorer           | ef
Telescope           | Find files             | Find files using Telescope                  | ff
Telescope           | Live grep              | Search text in files using Telescope        | fg
Telescope           | Buffers                | List open buffers using Telescope           | fb
Telescope           | Help tags              | Search help tags using Telescope            | fh
Telescope           | Current buffer fuzzy find| Fuzzy find text in the current buffer     | fs
Telescope           | LSP document symbols   | List LSP document symbols using Telescope   | fo
Telescope           | LSP incoming calls     | List LSP incoming calls using Telescope     | fi
Telescope           | Treesitter methods     | Find Treesitter methods using Telescope     | fm
Git-blame           | Toggle git blame        | Toggle Git blame view                       | gb
Harpoon             | Add file to Harpoon    | Add the current file to Harpoon             | ha
Harpoon             | Toggle Harpoon menu    | Toggle the Harpoon quick menu               | hh
Harpoon             | Navigate to file 1     | Navigate to the 1st file in Harpoon         | h1
Harpoon             | Navigate to file 2     | Navigate to the 2nd file in Harpoon         | h2
Harpoon             | Navigate to file 3     | Navigate to the 3rd file in Harpoon         | h3
Harpoon             | Navigate to file 4     | Navigate to the 4th file in Harpoon         | h4
Harpoon             | Navigate to file 5     | Navigate to the 5th file in Harpoon         | h5
Harpoon             | Navigate to file 6     | Navigate to the 6th file in Harpoon         | h6
Harpoon             | Navigate to file 7     | Navigate to the 7th file in Harpoon         | h7
Harpoon             | Navigate to file 8     | Navigate to the 8th file in Harpoon         | h8
Harpoon             | Navigate to file 9     | Navigate to the 9th file in Harpoon         | h9
Vim REST Console    | Run REST query         | Run a REST query using Vim REST Console     | xr
LSP                 | Hover                  | Show hover information from LSP             | gg
LSP                 | Go to definition       | Go to LSP definition                        | gd
LSP                 | Go to declaration      | Go to LSP declaration                       | gD
LSP                 | Go to implementation   | Go to LSP implementation                    | gi
LSP                 | Go to type definition  | Go to LSP type definition                   | gt
LSP                 | Go to references       | Go to LSP references                        | gr
LSP                 | Signature help         | Show LSP signature help                     | gs
LSP                 | Rename                 | Rename symbol using LSP                     | rr
LSP                 | Format                 | Format code using LSP                       | gf
LSP                 | Code action            | Perform LSP code action                     | ga
LSP                 | Open diagnostics       | Open diagnostic float window                | gl
LSP                 | Go to previous diagnostic| Go to previous diagnostic                   | gp
LSP                 | Go to next diagnostic  | Go to next diagnostic                       | gn
LSP                 | Document symbols       | Show document symbols using LSP             | tr
LSP                 | Autocomplete           | Trigger autocomplete using LSP              | <C-Space>
Debugging           | Toggle breakpoint      | Toggle a breakpoint in debugging            | bb
Debugging           | Set conditional breakpoint| Set a conditional breakpoint in debugging | bc
Debugging           | Set log point          | Set a log point in debugging                | bl
Debugging           | Clear breakpoints      | Clear all breakpoints                       | br
Debugging           | List breakpoints       | List all breakpoints                        | ba
Debugging           | Continue debugging     | Continue debugging                          | dc
Debugging           | Step over              | Step over in debugging                      | dj
Debugging           | Step into              | Step into in debugging                      | dk
Debugging           | Step out               | Step out in debugging                       | do
Debugging           | Disconnect debugging   | Disconnect from the debugger and close UI   | dd
Debugging           | Terminate debugging    | Terminate the debugger and close UI         | dt
Debugging           | Toggle REPL            | Toggle the REPL console                     | dr
Debugging           | Run last debug session | Run the last debug session                  | dl
Debugging           | Hover widgets          | Hover over debugging widgets                | di
Debugging           | Show scopes            | Show scopes in a centered float             | d?
Debugging           | List debug frames      | List debug frames using Telescope           | df
Debugging           | List debug commands    | List debug commands using Telescope         | dh
Debugging           | List diagnostics       | List diagnostics using Telescope            | de
