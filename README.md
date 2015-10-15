emacs.d from LDN
================

Brief uncomplete list of some usefull key bindings and commands

Links
-----

* <https://www.gnu.org/software/emacs/refcards/>
* <http://www.emacswiki.org/emacs/EmacsNewbieKeyReference>
* <http://ddloeffler.blogspot.fr/2013/04/keybindings-for-emacs-markdown-mode.html>

Key bindings
------------

### General
* C-u 0 `byte-recompile-directory`
* C-_ `undo`
* C-8 `redo` (require _redo+_)
* `find-file-at-point`

### Packages
ELPA = emacs lisp package archive
* M-x `list-packages`
* M-x `install-packages`

### File
* C-x C-m f (save and change encoding)
* C-x RET r = `revert-buffer-with-coding-system`
* M-x `set-buffer-file-coding-system` (Change linebreaking and encoding: undecided-unix, utf-8-unix (for LF), utf-8-mac (for CR) or utf-8-dos (for CR+LF))

### Window
* `toggle-truncate-lines`
* `toggle-word-wrap`

#### Multiple windows
* C-x 0 `delete-window` (delete the selected window)
* C-x 1 `delete-other-windows` (delete all windows in the selected frame except the selected window)
* C-x 2 `split-window-below` (split the selected window into two windows, one above the other)
* C-x 3 `split-window-right` (split the selected window into two windows, positioned side by side)

#### Resize window
* C-" => C-x } `enlarge-window-horizontally`
* C-x { `shrink-window-horizontally`
* `shrink-window`
* C-é => C-x ^ `enlarge-window`
* C-x = `balance-windows`

#### Move focus (some require _WindMove_)
* C-x o `other-window`
* M-{up,down,left,right} (move focus to other windows (require _Windmove_))
* M-t `transpose-frame` (require _Windmove_)
* M-r `rotate-frame-clockwise` (require _Windmove_)
* M-R `rotate-frame` (require _Windmove_)

### Edit file/code
* M-; `comment-dwim`
* C-M-a `beginning-of-defun`
* C-M-e `end-of-defun`
* `reverse-region`

#### Move in file
* C-l `recenter-top-bottom`
* C-< `beginning of file`
* C-> `end of file`
* C-a `beginning of line`
* C-e `end of line`
* M-g g `goto-line`

#### Rectangle selection
* C-x r t `string-rectangle`
* C-x r M-w `copy-rectangle-as-kill`
* C-x r k `kill-rectangle`
* C-x r y `yank-rectangle`

### Mode

#### Fortran mode
* C-u C-c C-w `fortran-window-create` (split the current window horizontally with a column ruler)
* C-M-j `fortran-split-line` (break the current line at point and set up a continuation line)
* C-M-q  `fortran-indent-subprogram` (indent all the lines of the subprogram where point is located)

#### csv-mode
* C-c C-a `csv-align-fields`
* C-c C-u `csv-unalign-fields`
* C-c C-k `csv-kill-fields`
* C-c C-y `csv-yank-fields`
* C-c C-t `csv-transpose`
* C-c C-s `csv-sort-fields` (sort by column in prescribing the colum index)

#### telemac-mode
* C-c d `telemac-open-dico`
* C-c h `telemac-keyword-popup-documentation`
* C-c l `telemac-toggle-lang`
* C-c m `telemac-set-module`

#### package-menu-mode
* Enter `describe-package`
* i `package-menu-mark-install`
* u `package-menu-mark-unmark`
* d `package-menu-mark-delete`
* x `package-menu-execute`
* r `package-menu-refresh`

#### markdown-mode

* C-c C-o `markdown-follow-link-at-point`

##### View

* S-TAB
* C-c C-c p `markdown-preview` (requires `markdown`)

##### Style

* C-c C-s e `markdown-insert-italic`
* C-c C-s s `markdown-insert-bold`
* C-c C-s c `markdown-insert-code`
* C-c C-s b `markdown-insert-blockquote`
* C-c C-s p `markdown-pre-region`

##### Heading

* C-c C-t h `markdown-insert-header-dwim`
* C-c C-t ! `markdown-insert-header-setext-1`
* C-c C-t @ `markdown-insert-header-setext-2`

### Emacs Lisp
* C-h f `describe-function`
* C-h v `describe-variable`

### dired mode
C-x d `dired`

* **ENT** Open the file
* **q**   Close the dir
* **C**   Copy file
* **R**   Rename/move file
* **D**   Delete file
* **+**   create a new dir

* **m**   mark a file
* **u**   unmark
* **U**   unmark all marked
* **%m**  mark by pattern (regex)

* **g**   refresh dir listing
* **^**   go to parent dir
* **(**  `dired-hide-details-mode`

### Other useful modes
* `calendar`
* `eww`
* `man`, `woman`
* `impatient-mode`

Procedures
----------

### Web developpement with automatic render (impatient-mode in html-mode)
1. `httpd-start`
2. `impatient-mode`
3. Web browser: <http://localhost:8080/imp> and select the corresponding buffer

### Interactively Find & Replace Text in Directory

1. Call `dired` to list files in dir, or call `find-dired` if you need all subdirectories
2. Mark the files you want. You can mark all files matching a pattern by typing `%m`
3. Type `Q` to call `dired-do-query-replace-regexp`
4. Type your find regex and replace string
5. For each occurrence, type `y` to replace, `n` to skip. Type `C-g` to abort the whole operation
6. Type `!` to replace all occurrences in current file without asking, `N` to skip all possible replacement for rest of the current file. (N is emacs 23 only)
7. To do the replacement on all files without further asking, type `Y`. (Emacs 23 only)
8. Call `ibuffer` to list all opened files.
9. Type `*u` to mark all unsaved files, type `S` to save all marked files, type `D` to close them all.

Source: <http://ergoemacs.org/emacs/find_replace_inter.html>
