# luneta [![Build Status](https://travis-ci.org/fbeline/luneta.svg?branch=master)](https://travis-ci.org/fbeline/luneta) [![luneta](https://snapcraft.io//luneta/badge.svg)](https://snapcraft.io/luneta)

Luneta is an interactive filter that can be easily composed within any script.

<p align="center">
  <img width="80%" src="https://user-images.githubusercontent.com/5730881/79627815-f864bc80-8111-11ea-9a14-11ab35f1962c.gif">
</p>

## About

- fast.
- small and portable. (~ 1mb binary)
- adaptable screen size.

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
ps -e -o pid,comm | luneta | awk '{print $2}' | xargs pkill
```

Check out [/examples](/examples) for more.

## Installation

It should work on any ANSI/POSIX-conforming unix.

[Precompiled binaries for linux](https://github.com/fbeline/luneta/releases)

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

MIT
