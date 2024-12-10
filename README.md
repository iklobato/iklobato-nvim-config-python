# Neovim Python Configuration Guide

## Quick Installation

```bash
curl -s https://raw.githubusercontent.com/iklobato/iklobato-nvim-config-python/install.sh | bash
```

## Keybinding Reference

### Essential Commands
| Shortcut | Description | Mnemonic |
|----------|-------------|----------|
| `wq` | Save and quit | "**W**rite and **Q**uit" |
| `qq` | Quit without saving | "**Q**uit **Q**uickly" |
| `ww` | Save current file | "**W**rite **W**rite" |
| `gx` | Open URL under cursor | "**G**oto e**X**ternal URL" |

### Window Management
| Shortcut | Description | Mnemonic |
|----------|-------------|----------|
| `sv` | Split window vertically | "**S**plit **V**ertically" |
| `sh` | Split window horizontally | "**S**plit **H**orizontally" |
| `se` | Make splits equal width | "**S**plit **E**qual" |
| `sx` | Close current split | "**S**plit e**X**it" |
| `sj` | Decrease window height | "**S**horten **J**ump" |
| `sk` | Increase window height | "**S**tretch **K**eep" |
| `sl` | Increase window width | "**S**tretch **L**onger" |
| `sm` | Toggle maximize window | "**S**ize **M**aximize" |

### Tab Management
| Shortcut | Description | Mnemonic |
|----------|-------------|----------|
| `to` | Open new tab | "**T**ab **O**pen" |
| `tx` | Close current tab | "**T**ab e**X**it" |
| `tn` | Next tab | "**T**ab **N**ext" |
| `tp` | Previous tab | "**T**ab **P**revious" |

### File Navigation
| Shortcut | Description | Mnemonic |
|----------|-------------|----------|
| `ee` | Toggle file explorer | "**E**xplorer **E**nable" |
| `er` | Focus file explorer | "**E**xplorer **R**e-focus" |
| `ef` | Find file in explorer | "**E**xplorer **F**ind" |

### Search and Find
| Shortcut | Description | Mnemonic |
|----------|-------------|----------|
| `ff` | Find files | "**F**ind **F**iles" |
| `fg` | Live grep | "**F**ind **G**rep" |
| `fb` | List buffers | "**F**ind **B**uffers" |
| `fh` | Search help tags | "**F**ind **H**elp" |
| `fs` | Fuzzy find in buffer | "**F**uzzy **S**earch" |
| `fo` | List LSP symbols | "**F**ind **O**bjects" |
| `fi` | List incoming calls | "**F**ind **I**ncoming" |
| `fm` | Find methods | "**F**ind **M**ethods" |

### Git Integration
| Shortcut | Description | Mnemonic |
|----------|-------------|----------|
| `gb` | Toggle git blame | "**G**it **B**lame" |

### LSP Features
| Shortcut | Description | Mnemonic |
|----------|-------------|----------|
| `gg` | Show hover info | "**G**et **G**eneral" |
| `gd` | Go to definition | "**G**o **D**efinition" |
| `gD` | Go to declaration | "**G**o **D**eclaration" |
| `gi` | Go to implementation | "**G**o **I**mplementation" |
| `gt` | Go to type definition | "**G**o **T**ype" |
| `gr` | Find references | "**G**o **R**eferences" |
| `gs` | Show signature help | "**G**et **S**ignature" |
| `rr` | Rename symbol | "**R**e**R**ename" |
| `gf` | Format code | "**G**o **F**ormat" |
| `ga` | Code action | "**G**o **A**ction" |
| `gl` | Open diagnostics | "**G**et **L**ast" |
| `gp` | Previous diagnostic | "**G**o **P**revious" |
| `gn` | Next diagnostic | "**G**o **N**ext" |
| `tr` | Show document symbols | "**T**ag **R**eference" |
| `<C-Space>` | Trigger autocomplete | "**C**trl **Space**" |

### Debugging
| Shortcut | Description | Mnemonic |
|----------|-------------|----------|
| `bb` | Toggle breakpoint | "**B**reakpoint **B**oth" |
| `bc` | Set conditional breakpoint | "**B**reakpoint **C**onditional" |
| `bl` | Set log point | "**B**reakpoint **L**og" |
| `br` | Clear all breakpoints | "**B**reakpoint **R**emove" |
| `ba` | List breakpoints | "**B**reakpoints **A**ll" |
| `dc` | Continue debugging | "**D**ebug **C**ontinue" |
| `dj` | Step over | "**D**ebug **J**ump" |
| `dk` | Step into | "**D**ebug **K**eep" |
| `do` | Step out | "**D**ebug **O**ut" |
| `dd` | Disconnect debugger | "**D**ebug **D**isconnect" |
| `dt` | Terminate debugging | "**D**ebug **T**erminate" |
| `dr` | Toggle REPL | "**D**ebug **R**EPL" |
| `dl` | Run last debug session | "**D**ebug **L**ast" |
| `di` | Debug info (hover) | "**D**ebug **I**nfo" |
| `d?` | Show scopes | "**D**ebug **?**scopes" |
| `df` | List debug frames | "**D**ebug **F**rames" |
| `dh` | List debug commands | "**D**ebug **H**elp" |
| `de` | List diagnostics | "**D**ebug **E**rrors" |

### Diff Operations
| Shortcut | Description | Mnemonic |
|----------|-------------|----------|
| `cc` | Put diff | "**C**ompare **C**hanges" |
| `cj` | Get diff from left | "**C**ompare **J**ump left" |
| `ck` | Get diff from right | "**C**ompare **K**eep right" |
| `cn` | Next diff hunk | "**C**ompare **N**ext" |
| `cp` | Previous diff hunk | "**C**ompare **P**revious" |

### Quickfix List
| Shortcut | Description | Mnemonic |
|----------|-------------|----------|
| `qo` | Open quickfix list | "**Q**uickfix **O**pen" |
| `qf` | Jump to first item | "**Q**uickfix **F**irst" |
| `qn` | Jump to next item | "**Q**uickfix **N**ext" |
| `qp` | Jump to previous item | "**Q**uickfix **P**revious" |
| `ql` | Jump to last item | "**Q**uickfix **L**ast" |
| `qc` | Close quickfix list | "**Q**uickfix **C**lose" |

### REST Client
| Shortcut | Description | Mnemonic |
|----------|-------------|----------|
| `xr` | Run REST query | "e**X**ecute **R**EST" |
