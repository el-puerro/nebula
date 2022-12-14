#!/usr/bin/env bash

rg -g '!tools/*' -i TODO --vimgrep | awk '{split($1,arr,":"); print "\"git blame -f -n -L"  arr[2] "," arr[2], arr[1] "\""}' | xargs -n1 bash -c | rg "`git config --global user.name`"
