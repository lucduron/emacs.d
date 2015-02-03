EMACS.D FROM LDN
================

Brief list of some usefull key bindings and commands

# Links
* https://www.gnu.org/software/emacs/refcards/
* http://www.emacswiki.org/emacs/EmacsNewbieKeyReference
* http://ddloeffler.blogspot.fr/2013/04/keybindings-for-emacs-markdown-mode.html

# General
*               list-packages                 List of packages
* C-u 0         byte-recompile-directory      Byte-compile a directory

# File
* C-x C-w f                                   Save and change encoding
* M-x set-buffer-file-coding-system [undecided-unix, utf-8-unix (for LF), utf-8-mac (for CR) or utf-8-dos (for CR+LF)]         change linebreaking and encoding

# Window
*               toggle-truncate-lines

## Manage multiple windows
* C-x 0         delete-window         Delete the selected window
* C-x 1         delete-other-windows  Delete all windows in the selected frame except the selected window
* C-x 2         split-window-below    Split the selected window into two windows, one above the other
* C-x 3         split-window-right    Split the selected window into two windows, positioned side by side

## Resize window
+ C-" => C-x }  enlarge-window-horizontally  Make selected window wider
* C-x {         shrink-window-horizontally   Make selected window narrower
*               shrink-window                Make selected window smaller
+ C-é => C-x ^  enlarge-window               Make selected window taller
* C-x +         balance-windows              Balance frame size

## Move windows (some require WindMove)
* C-x o         other-window               Select another window
+ M-{up,down,left,right}                   Move focus to other windows (Windmove package)
+ M-t           transpose-frame
+ M-r           rotate-frame-clockwise     Rotation 90°
+ M-R           rotate-frame               Rotation 180°

# Edit file/code
* C-_                                      Undo
* C-8                                      Redo (require redo)

## Move in file
* C-l           recenter-top-bottom
* C-<           beginning of file
* C->           end of file
* C-a           beginning of line
* C-e           end of line
* M-g g         goto-line

## Rectangle selection
* C-x r t       string-rectangle           Replace rectangle contents with a string on each line
* C-x r M-w     copy-rectangle-as-kill     Save the text of the region-rectangle as the last killed rectangle
* C-x r k       kill-rectangle
* C-x r y       yank-rectangle             Yank the last killed rectangle with its upper left corner at point

## Code source
* M-;                                      Comment...
* C-M-a         beginning-of-defun         Move to beginning of current or preceding defun
* C-M-e         end-of-defun               Move to end of current or following defun

## Fortran Mode
* M-;           fortran-comment-indent     Align comment or insert new comment
* C-u C-c C-w   fortran-window-create      Split the current window horizontally with a column ruler
* C-M-j         fortran-split-line         Break the current line at point and set up a continuation line
* C-M-q         fortran-indent-subprogram  Indent all the lines of the subprogram point is in

## CSV mode
* C-c C-a         csv-align-fields       Aligns fields into columns
* C-c C-u         csv-unalign-fields     Undoes such alignment separators
* C-c C-k         csv-kill-fields
* C-c C-y         csv-yank-fields
* C-c C-t         csv-transpose          Interchanges rows and columns
