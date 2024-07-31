Neovim Configuration Features

1. **Leader Key**:
   - The leader key is set to space (`<Space>`).

2. **General Keymaps**:
   - Save and quit: `<leader>wq`
   - Quit without saving: `<leader>qq`
   - Save: `<leader>ww`
   - Open URL under cursor: `gx`

3. **Split Window Management**:
   - Split window vertically: `<leader>sv`
   - Split window horizontally: `<leader>sh`
   - Make split windows equal width: `<leader>se`
   - Close split window: `<leader>sx`
   - Make split window height shorter: `<leader>sj`
   - Make split windows height taller: `<leader>sk`
   - Make split windows width bigger: `<leader>sl`
   - Make split windows width smaller: `<leader>sh`

4. **Tab Management**:
   - Open a new tab: `<leader>to`
   - Close a tab: `<leader>tx`
   - Switch to next tab: `<leader>tn`
   - Switch to previous tab: `<leader>tp`

5. **Diff Keymaps**:
   - Put diff from current to other: `<leader>cc`
   - Get diff from left (local): `<leader>cj`
   - Get diff from right (remote): `<leader>ck`
   - Jump to next diff hunk: `<leader>cn`
   - Jump to previous diff hunk: `<leader>cp`

6. **Quickfix Keymaps**:
   - Open quickfix list: `<leader>qo`
   - Jump to first quickfix item: `<leader>qf`
   - Jump to next quickfix item: `<leader>qn`
   - Jump to previous quickfix item: `<leader>qp`
   - Jump to last quickfix item: `<leader>ql`
   - Close quickfix list: `<leader>qc`

7. **Vim-Maximizer**:
   - Toggle maximize tab: `<leader>sm`

8. **Nvim-tree**:
   - Toggle file explorer: `<leader>ee`
   - Focus on file explorer: `<leader>er`
   - Find file in file explorer: `<leader>ef`

9. **Telescope**:
   - Find files: `<leader>ff`
   - Live grep: `<leader>fg`
   - List buffers: `<leader>fb`
   - Search help tags: `<leader>fh`
   - Fuzzy find in current buffer: `<leader>fs`
   - List LSP document symbols: `<leader>fo`
   - List LSP incoming calls: `<leader>fi`
   - List treesitter methods: `<leader>fm`

10. **Git-blame**:
    - Toggle git blame: `<leader>gb`

11. **Harpoon**:
    - Add file to Harpoon: `<leader>ha`
    - Toggle Harpoon quick menu: `<leader>hh`
    - Navigate to specific Harpoon file marks: `<leader>h1` to `<leader>h9`

12. **Vim REST Console**:
    - Run REST query: `<leader>xr`

13. **LSP (Language Server Protocol)**:
    - Hover: `<leader>gg`
    - Go to definition: `<leader>gd`
    - Go to declaration: `<leader>gD`
    - Go to implementation: `<leader>gi`
    - Go to type definition: `<leader>gt`
    - Show references: `<leader>gr`
    - Show signature help: `<leader>gs`
    - Rename: `<leader>rr`
    - Format code: `<leader>gf` (normal and visual mode)
    - Show code actions: `<leader>ga`
    - Show diagnostics: `<leader>gl`
    - Navigate to previous diagnostic: `<leader>gp`
    - Navigate to next diagnostic: `<leader>gn`
    - Show document symbols: `<leader>tr`
    - Trigger completion: `<C-Space>`

14. **Debugging**:
    - Toggle breakpoint: `<leader>bb`
    - Set breakpoint with condition: `<leader>bc`
    - Set log point: `<leader>bl`
    - Clear breakpoints: `<leader>br`
    - List breakpoints: `<leader>ba`
    - Continue execution: `<leader>dc`
    - Step over: `<leader>dj`
    - Step into: `<leader>dk`
    - Step out: `<leader>do`
    - Disconnect and close UI: `<leader>dd`
    - Terminate and close UI: `<leader>dt`
    - Toggle REPL: `<leader>dr`
    - Run last: `<leader>dl`
    - Hover widgets: `<leader>di`
    - Centered float scopes: `<leader>d?`
    - List frames: `<leader>df`
    - List commands: `<leader>dh`
    - Show diagnostics in Telescope: `<leader>de`

