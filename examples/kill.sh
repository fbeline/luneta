#!/bin/sh
set -e

name=$(ps -e -o comm | luneta)
pkill $name
