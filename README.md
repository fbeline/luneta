<p align="center">
  <img width="388" height="70" src="https://user-images.githubusercontent.com/5730881/79414815-01268880-7f82-11ea-8f46-f526f829bd69.png">
</p>

[![Build Status](https://travis-ci.org/fbeline/luneta.svg?branch=master)](https://travis-ci.org/fbeline/luneta)
![v0.1.0-beta](https://img.shields.io/badge/v0.1.0--beta-blue)

![luneta](https://user-images.githubusercontent.com/5730881/79627815-f864bc80-8111-11ea-9a14-11ab35f1962c.gif)

## Usage examples

Pick a command in your shell history:
```bash
cat ~/.bash_history | luneta 
```

Execute a program locate in `/usr/bin`:
```bash
ls /usr/bin | luneta | xargs -0 bash -c
```

Kill an active process:
```bash
ps -aux | luneta | awk '{print $2}' | xargs kill -8
```

Check out [/examples](/examples) for more.

## installation

#### Manual
- See the [building](#building) section.

## Requirements
It should work on any ANSI/POSIX-conforming unix.

## Building
Prerequisites: 
- [dmd](https://dlang.org/download.html)
- [dub](https://code.dlang.org/download)
- ncurses

```bash
git clone https://github.com/fbeline/luneta
cd luneta
dub build
```

## License
MIT
