# Usage:
# * linux: make compile
# * cygwin: make cygwin

SAVE = ~/.emacs.d_OLD
EDOT = ~/.emacs.d

install:
	-rm  -rf $(SAVE)
	-mv $(EDOT) $(SAVE)
	-mkdir $(EDOT)
	cp * $(EDOT) -r

compile: install
	emacs --batch --eval '(byte-recompile-directory (expand-file-name "~/.emacs.d") 0)'

cygwin: install
	cat $(EDOT)/init_cygwin.el >> $(EDOT)/init.el
	emacs-w32 --batch --eval '(byte-recompile-directory (expand-file-name "~/.emacs.d") 0)'

.PHONY: install cygwin compile
