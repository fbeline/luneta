#!/bin/bash
dub build -b release --compiler ldc2
tar -czvf luneta-linux-amd64.tar.gz ./luneta