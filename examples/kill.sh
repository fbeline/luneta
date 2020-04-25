#!/bin/sh
ps -e -o pid,comm | luneta | awk '{print $2}' | xargs pkill