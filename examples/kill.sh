#!/bin/sh
ps -aux | luneta | awk '{print $2}' | xargs kill -8