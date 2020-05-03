#!/bin/bash
mkdir -p releases
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
dub build -b release --compiler ldc2
tar -czvf releases/luneta-$machine-amd64.tar.gz ./luneta