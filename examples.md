# Examples

List of examples to demonstrates how to use luneta.

## Hello world

```bash
echo "hello\nworld\nluneta" | luneta
```

## Kill an active process

```bash
function ik {
    local pname
    pname=$(ps -e -o comm 2> /dev/null | luneta) && pkill "${pname}"
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
git branch 2> /dev/null | luneta | sed "s/.* //" | awk '{print $1}' | xargs git checkout
```

## Docker

Stop container

```bash
function docker-stop {
  local id
  id=$(docker ps 2> /dev/null | sed 1d | luneta) \
   && echo "${id}" | awk '{print $1}' | xargs docker stop
}
```