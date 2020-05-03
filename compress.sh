#!/bin/bash
mkdir -p releases
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=linux;;
    Darwin*)    machine=osx;;
    CYGWIN*)    machine=cygwin;;
    MINGW*)     machine=minGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
dub build -b release --compiler ldc2
tar -czvf releases/luneta-$machine-amd64.tar.gz ./luneta