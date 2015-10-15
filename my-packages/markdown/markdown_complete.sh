#!/bin/sh
# Concatenate input file (filename as argument) with html header file

cat ~/.emacs.d/my-packages/markdown/header.html $* | markdown
