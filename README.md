# luneta [![Build Status](https://travis-ci.org/fbeline/luneta.svg?branch=master)](https://travis-ci.org/fbeline/luneta) [![luneta](https://snapcraft.io//luneta/badge.svg)](https://snapcraft.io/luneta)

Luneta is an interactive filter that can be easily composed within any script.

It's a fast and lightweight terminal tool that brings swiftness to your daily hacks. :shell:

![terminal](https://user-images.githubusercontent.com/5730881/80448528-f3162780-88f2-11ea-9d2b-82f1b31b727c.png)

## About

- fast.
- small binary. (~ 1mb)
- adaptable screen size.
- Supports terminals that are not capable of redefining colors.
[_--no-color_](https://asciinema.org/a/321218)

Run `luneta -h` for help.

## Usage examples

Pick a command in your shell history:

```bash
cat ~/.bash_history | luneta
```

Checkout a git branch:

```bash
git branch | luneta | xargs git checkout
```

Kill an active process:

```bash
ps -e -o comm | luneta | xargs pkill
```

Check out [/examples](/examples) for more.

## Keyboard shorcuts

- CTRL + n: next selection
- CTRL + p: previous selection
- CTRL + a: beggining of the line
- CTRL + e: end of the line
- CTRL + u: erase all the character before and after the cursor
- CTRL + d: exit

## Installation

It should work on any ANSI/POSIX-conforming unix.

[Precompiled binaries for linux](https://github.com/fbeline/luneta/releases) - _Make shure that you have_ **libncurses** _installed._

### Snap

[Linux distributions that support snaps](https://snapcraft.io/docs/installing-snapd).

`snap install luneta`

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

## License

GPL-2.0
