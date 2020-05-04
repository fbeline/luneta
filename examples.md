# Examples

## Hello world

```bash
echo "hello\nworld\nluneta" | luneta
```

## Kill an active process

```bash
function ik {
    local pname
    pname=$(ps -e -o comm | luneta) && pkill $pname
}
```

## Directory navigation

```bash
function jump {
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null | luneta) && cd "${dir}"
}
```
## Opening files

Search and open files with vim.

```bash
function of {
  local f
  f=$(find ${1:-.} -type f 2> /dev/null | luneta) && vim "${f}"
}
```

## Checkout git branch

```bash
git branch 2>/dev/null | luneta | sed "s/.* //" | awk '{print $1}' | xargs git checkout
```

## Docker

Stop container

```bash
  local id
  id=$(docker ps | sed 1d | luneta | awk '{print $1}') && docker stop "${id}"
```

