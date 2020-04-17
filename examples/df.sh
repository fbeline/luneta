#!/bin/sh
# shows available and used disk space on the Linux system.
df -h | tail -n +2 | luneta | awk '{print $6}'