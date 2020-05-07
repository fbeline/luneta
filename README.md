# luneta [![Build Status](https://travis-ci.org/fbeline/luneta.svg?branch=master)](https://travis-ci.org/fbeline/luneta) [![luneta](https://snapcraft.io//luneta/badge.svg)](https://snapcraft.io/luneta)

Luneta is an interactive filter that can be easily composed within any script.

![render1588879971924](https://user-images.githubusercontent.com/5730881/81336973-9cda7e80-9080-11ea-91e9-0ad212ca2591.gif)

## About

- Fast
- Small binary (~ 1mb)
- Multiple line selection
- Supports terminals that are not capable of redefining colors [_--color=FALSE_](https://asciinema.org/a/321218)

Run `luneta -h` for help:

```
usage: luneta [options]
-v --version version
-q   --query default query to be used upon startup
-f  --filter do not start interactive finder, e.g -f="pattern"
    --height set the maximum window height (number of lines), e.g --height 25
     --color color support, e.g --color=FALSE
-h    --help This help information.
```

## Installation

### Brew

`brew install fbeline/luneta/luneta`

### Snap

`snap install luneta`

### Precompiled binaries

[Releases](https://github.com/fbeline/luneta/releases) - 
note: `libncurses` is required.

### Manual Installation

Prerequisites:

- [ldc](https://dlang.org/download.html)
- [dub](https://code.dlang.org/download)
- ncurses

```bash
git clone https://github.com/fbeline/luneta
cd luneta
dub build -b release --compiler ldc2
```

## Usage examples

Search a command in your shell history:

```bash
fc -ln 1 | luneta
```

Checkout a git branch:

```bash
git branch 2>/dev/null | luneta | sed "s/.* //" | awk '{print $1}' | xargs git checkout
```

Kill an active process:

```bash
ps -e -o comm | luneta | xargs pkill
```

Refer to the [examples](/examples.md) for more.

## Use with Vim

Just paste the code bellow in your `.vimrc` to use luneta as your file seaching tool.

```
" Run a given vim command on the results of fuzzy selecting from a given shell
" command. See usage below.
function! LunetaCommand(choice_command, vim_command)
  try
    let output = system(a:choice_command . " | luneta ")
  catch /Vim:Interrupt/
    " Swallow the ^C so that the redraw below happens; otherwise there will be
    " leftovers from luneta on the screen
    endtry
    redraw!
  if v:shell_error == 0 && !empty(output)
    exec a:vim_command . ' ' . output
  endif
endfunction

" Find all files in all non-dot directories starting in the working directory.
" Fuzzy select one of those and open the selected file.
nnoremap <leader>e :call LunetaCommand("find . -type f", ":e")<cr>
nnoremap <leader>v :call LunetaCommand("find . -type f", ":vs")<cr>
nnoremap <leader>s :call LunetaCommand("find . -type f", ":sp")<cr>
```

For better results is recommended to use searching tools like
[ag](https://github.com/ggreer/the_silver_searcher),
[rg](https://github.com/BurntSushi/ripgrep),
[ack](https://beyondgrep.com/), etc.

```
nnoremap <leader>e :call LunetaCommand("ag . --silent -l", ":e")<cr>
nnoremap <leader>v :call LunetaCommand("ag . --silent -l", ":vs")<cr>
nnoremap <leader>s :call LunetaCommand("ag . --silent -l", ":sp")<cr>
```

*This vimscript is a modified version of the [selecta](https://github.com/garybernhardt/selecta#use-with-vim).

## Keyboard shorcuts

| Key | Action |
|-----|--------|
| CTRL + Space | Select line and move to the next item |
| CTRL + n | next selection  |
| CTRL + p | previous selection  |
| CTRL + a | beggining of the line  |
| CTRL + e | end of the line  |
| CTRL + u | erase all the character before and after the cursor |
| CTRL + d | exit |

## License

GPL-2.0
