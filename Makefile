# Brief:
#   byte-compile folder ~/.emacs.d/
# Usage:
# * linux: `make compile`
# * cygwin: `make cygwin`

EDOT = ~/.emacs.d

compile:
	emacs --batch --eval '(byte-recompile-directory (expand-file-name "~/.emacs.d") 0)'

cygwin:
	cat $(EDOT)/init_cygwin.el >> $(EDOT)/init.el
	emacs-w32 --batch --eval '(byte-recompile-directory (expand-file-name "~/.emacs.d") 0)'

.PHONY: compile cygwin
