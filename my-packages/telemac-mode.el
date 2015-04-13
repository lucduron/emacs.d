;;; telemac-mode.el --- Emacs Major mode for telemac cas formatted text files
;;
;; Author: LDN
;; Version: 0.9
;; Keywords: opentelemac, keyword, cas file
;; recommended version of Emacs : >=24.4

;; ~> Brief:
;; Major mode to edit telemac cas files.
;; Features : syntax highlighting, autocompletion and keyword documentation
;;
;; ~> How to install
;; * this file should be in the `load-path' (define it in your emacs init file)
;; * the path to the folder containing the subfolders dico, definitions and lists should be correctly defined in the variable `telemac-mode-folder'
;; * auto-complete package (with popup) is recommended and compulsory for some functions (see dependencies below)
;; By default, if the file telemac-mode.el and the folder telemac-mode
;;   are placed in the folder ~/.emacs/my-packages, it should work.
;;
;; ~> How to use?
;; 1) load this module (M-x `telemac-mode').
;;    To load automatically this module if the filename extension is .cas,
;;      add the following emacs lisp code :
;;    (add-to-list 'auto-mode-alist '("\\.cas\\'" . telemac-mode))
;; 2) Define the module and the language of the current cas file,
;;    The default values of variables `telemac-module' and `telemac-lang' are read.
;;    `telemac-module' is overwritten automatically if the filename is starting with a prefix
;;    corresponding a module abbreviation.
;;    (for example, t2d preffix will load module telemac2d. See body of `telemac-mode')
;;    Finally you can set the variables manually by calling the specific functions presented below.
;;
;; ~> How to call a function? There are many ways:
;;      * in graphical mode, the menu-bar called "Telemac" displays the functions
;;      * with key bindings (C-c followed by d, h, l or m, They are defined in `telemac-mode-map')
;;      * interactively with M-x followed by the function name
;;
;; ~> Functions:
;; * `telemac-set-module' => Select telemac module
;; * `telemac-toggle-lang' => Toggle keyword language (between french and english)
;; * `telemac-keyword-popup-documentation' => Keyword documentation
;; * `telemac-open-dico' => Open dico file
;; * `telemac-comment-dwim' => (Un-)comment region or add inline comment
;;
;; ~ Dependencies (optional but recommended):
;; * `telemac-load-module' requires `auto-complete' for keyword completion
;; * `telemac-keyword-popup-documentation' requires `popup' to display keyword documentation
;;
;; ~> Known bugs/problems
;; * '/' inside a quotation mark is displayed as a comment (for example: FILE = '../path/file')
;; * `telemac-lang' and `telemac-module' are defined locally (for each buffer) but code is not so clean
;; * `popup-tip' does not support scrolling? => problem wih long documentation
;; * Assignement character present in quotation mark are not considered as string. Therefore documentation of the line "TITLE = 'foo: bar" is not possible (2 assignement symbols are found, then 2 keywords are expected...)
;; * auto-completion only works with the first word (no completion with whitespace)

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;; VARIABLES

(defgroup telemac nil
  "Major mode for editing telemac cas files.")

; Folder with keywords of each modules
(defcustom telemac-mode-folder "~/.emacs.d/my-packages/telemac-mode"
  "Path to telemac keywords for dictionary and definitions"
  :group 'telemac
  :type 'string)

; keywords module
(defcustom telemac-module "telemac2d"
  "Telemac module for keyword highlighting and auto-completion.
Can be set interactively locally (for the current buffer) with `telemac-set-module'"
  :group 'telemac
  :type 'string)

(defcustom telemac-lang "fr"
  "Telemac language to define keywords.
Can be set interactively locally (for the current buffer) with `telemac-toggle-lang'"
  :group 'telemac
  :type 'string)

;; Local variables (not very clean, but not working easily with a major mode)
(make-variable-buffer-local 'telemac-module-local)
(make-variable-buffer-local 'telemac-lang-local)
(make-variable-buffer-local 'active-module-prefix-local)
(make-variable-buffer-local 'cas-keywords)

;; FUNCTIONS

(defun telemac-set-module (arg)
  "Change `telemac-module' interactively. Completing is activated."
  (interactive
    (list
      (completing-read "Set module name locally: " '("artemis" "postel3d" "sisyphe" "stbtel" "telemac2d" "telemac3d" "tomawac"))))
  (setq telemac-lang telemac-lang-local) ; avoid conflict `telemac-toggle-lang'
  (setq telemac-module arg)
  (setq telemac-module-set t)
  (telemac-mode))

(defun telemac-toggle-lang ()
  "Change telemac language (`telemac-lang') interactively"
  (interactive)
  (setq telemac-module telemac-module-local) ; avoid conflict with `telemac-set-module'
  (if (string= telemac-lang "en")
    (setq telemac-lang "fr")
    (setq telemac-lang "en"))
  (telemac-mode))


(defun read-lines (filePath)
  "Return file content in a string (with \n as line separator)"
  (with-temp-buffer
    (insert-file-contents filePath)
    (buffer-string)))

;; command to comment/uncomment text
(defun telemac-comment-dwim (arg)
  "Comment or uncomment current line or region in a smart way"
  (interactive "*P")
  (require 'newcomment)
  (let
    ((comment-start "/") (comment-end ""))
    (comment-dwim arg)))

;; syntax table
(defvar telemac-syntax-table nil "Syntax table for `telemac-mode'.")
(setq telemac-syntax-table
  (let ((synTable (make-syntax-table)))

  ;; style comment: "/ …"
  (modify-syntax-entry ?/ "< b" synTable)
  (modify-syntax-entry ?\n "> b" synTable)

  ;; simple quotation mark
  ;;(modify-syntax-entry ?' "| '" synTable)
  ;; /!\ Above is not working because simple quote is used in some french keywords...

  synTable))

(defun telemac-load-module (module lang)
  "Load corresponding telemac module :
   * keyword list for hightlighting and autocomplete
   * definition for popup"
  (setq cas-keywords (read-lines (joindirs telemac-mode-folder "lists" lang module)))
  (setq cas-keywords (split-string cas-keywords "\n" t)) ; transform as list

  ;; create the regex string for each class of keywords
  (setq cas-keywords-regexp (regexp-opt cas-keywords 'words))
  (setq cas-booleans-regexp (regexp-opt cas-booleans 'words))
  (setq cas-meta-functions-regexp (regexp-opt cas-meta-functions))
  (setq cas-characters-regexp (regexp-opt cas-characters))

  (setq simple-quoted-string-regexp "'\\(\\\\[\\\\']\\|[^\\\\']\\)*'")

  ;; create the list for font-lock.
  ;; each class of keyword is given a particular face
  (setq cas-font-lock-keywords
    `(
      (,cas-keywords-regexp . font-lock-variable-name-face)
      (,simple-quoted-string-regexp . font-lock-string-face)
      (,cas-booleans-regexp . font-lock-type-face)
      (,cas-meta-functions-regexp . font-lock-keyword-face)
      (,cas-characters-regexp . font-lock-constant-face)
      ; note: order above matters. “cas-keywords-regexp” goes first because
      ; otherwise the keyword “VERSION NON-HYDROSTATIQUE” will not be highlighted because "NON" is a also constant...
      ))

  ;; AUTO COMPLETE
  (when (require 'auto-complete nil 'noerror)
    (add-to-list 'ac-modes 'telemac-mode)
    ;comint-dynamic-list-filename-completions is enabled automatically

    (make-local-variable 'ac-user-dictionary-files)
    ; Add user dictonnary corresponding to the target module
    (add-to-list 'ac-user-dictionary-files (joindirs telemac-mode-folder "lists" lang module))))

(defun telemac-open-dico ()
  "Open the telemac dictionary file of the current module
(defined by the variable `telemac-module').
The dico file contains both languages (ie `telemac-lang' is not used)"
  (interactive)
  (find-file (joindirs telemac-mode-folder "dico" (concat telemac-module ".dico"))))


(defun telemac-keyword-popup-documentation ()
  "Find the documentation of the current keyword and display it in
a popup."
  (interactive)
  ;; POPUP
  (require 'popup)

  ;; Local functions
  (defun count-occurences (regex string)
    "Count occurence(s) of regex in string. Require `recursive-count'"
    (recursive-count regex string 0))
  (defun recursive-count (regex string start)
    (if (string-match regex string start)
      (+ 1 (recursive-count regex string (match-end 0))) 0))

  (defun trim-string (string)
    "Remove white spaces in beginning and ending of STRING.
White space here is any of: space, tab, emacs newline"
    (replace-regexp-in-string "\\`[ \t\n]*" "" (replace-regexp-in-string "[ \t\n]*\\'" "" string)))
  ;; End of local functions

  (setq line (thing-at-point 'line)) ; get current line
  (setq line (car (split-string line "/"))) ; remove commented part (can remove a path)
  (setq line (replace-regexp-in-string "=" ":" line)) ; keep a single assignement character
  (setq nb_keywords (count-occurences ":" line)) ; number of assignement character(s)

  (if (> nb_keywords 1)
    (message "Too many keywords in the current line (%d separators)" nb_keywords)
    ;; (else) 0 or 1 keyword found
    (progn
      (setq line (car (split-string line ":")))
      (setq keyword (trim-string line))
      (if (string= keyword "")
        ;; String keyword is empty
        (message "No keyword found in current line")
        (if (member keyword cas-keywords)
          ;; Documentation is displayed in a popup
          (progn
            (message "Documentation of keyword \"%s\" (from %s in %s)" keyword telemac-module-local telemac-lang-local)
	    (setq def_file (joindirs telemac-mode-folder "definitions" telemac-lang-local telemac-module-local keyword))
	    (setq text (read-lines def_file))
	    (setq text (replace-regexp-in-string "\n" "
" text)) ; line breakings in orignal dico file are kept
	    (popup-tip text :scroll-bar t) ; FIXME: scroll-bar is displayed but not working???
          )
          ;; (else) Keyword is not in the list
          (message "Keyword \"%s\" is unknown (from %s in %s)" keyword telemac-module-local telemac-lang-local)
        )))))

(defun joindirs (root &rest dirs)
  "Joins a series of directories together, like Python's os.path.join,
(dotemacs-joindirs \"/tmp\" \"a\" \"b\" \"c\") => /tmp/a/b/c"
  (if (not dirs)
    root
    (apply 'joindirs
    (expand-file-name (car dirs) root)
    (cdr dirs))))

;; DEFINE KEY BINDINGS AND MENU
(defvar telemac-mode-map
  (let ((map (make-keymap)))
  ;; New key bindings
  (define-key map (kbd "C-c d") 'telemac-open-dico)
  (define-key map (kbd "C-c h") 'telemac-keyword-popup-documentation)
  (define-key map (kbd "C-c l") 'telemac-toggle-lang)
  (define-key map (kbd "C-c m") 'telemac-set-module)

  ;; make comment command “telemac-comment-dwim” use the current key for “comment-dwim”
  (define-key map [remap comment-dwim] 'telemac-comment-dwim)

  ;; define the menu (for GNU Emacs and XEmacs)
  ;; Help here: http://ergoemacs.org/emacs/elisp_menu_for_major_mode.html
  (define-key map [menu-bar] (make-sparse-keymap))

  (let ((menuMap (make-sparse-keymap "Telemac")))
    (define-key map [menu-bar telemac] (cons "Telemac" menuMap))

    (define-key menuMap [module] '("Select telemac module" . telemac-set-module))
    (define-key menuMap [lang] '("Toggle keyword language" . telemac-toggle-lang))
    (define-key menuMap [help] '("Keyword documentation" . telemac-keyword-popup-documentation))
    (define-key menuMap [dico] '("Open dico file" . telemac-open-dico))
  ) map)
  "Keymap for Telemac major mode.")

;; DEFINE MAJOR MODE
(define-derived-mode telemac-mode fundamental-mode "Telemac"
  "Major mode for editing openTELEMAC cas file"
  :syntax-table telemac-syntax-table
  (let (
    ;; Definition of some symbols
    (cas-booleans '("TRUE" "true" "FALSE" "false" "YES" "yes" "NO" "no" "VRAI" "vrai" "FAUX" "faux" "OUI" "oui" "NON" "non"))
    (cas-meta-functions '("&FIN" "&ETA" "&LIS" "&IND" "&STO"))
    (cas-characters '(":" "=" ";" ",")))

  (setq mode-name "telemac-mode")

  (if (boundp 'telemac-module-set)
    (if (not telemac-module-set)
      ;; Check if the prefix of the filename is the abbrevation of a module
      (cond
        ((equal (string-match "art" (buffer-name)) 0) (setq telemac-module "artemis"))
        ((equal (string-match "p3d" (buffer-name)) 0) (setq telemac-module "postel3d"))
        ((equal (string-match "sis" (buffer-name)) 0) (setq telemac-module "sisyphe"))
        ((equal (string-match "stb" (buffer-name)) 0) (setq telemac-module "stbtel"))
        ((equal (string-match "t2d" (buffer-name)) 0) (setq telemac-module "telemac2d"))
        ((equal (string-match "t3d" (buffer-name)) 0) (setq telemac-module "telemac3d"))
        ((equal (string-match "tom" (buffer-name)) 0) (setq telemac-module "tomawac"))
      )))

  ;; Save configuration in local variables (for documentation)
  (setq telemac-module-local telemac-module)
  (setq telemac-lang-local telemac-lang)

  (message "Load keywords from module %s in %s" telemac-module-local telemac-lang-local)
  (telemac-load-module telemac-module-local telemac-lang-local)

  ;; code for syntax highlighting
  (setq font-lock-defaults '((cas-font-lock-keywords)))
  ;; (font-lock-add-keywords 'telemac-mode '((simple-quoted-string-regexp 1 font-lock-string-face t)))

  ;; clear memory
  (setq cas-keywords-regexp nil)
  (setq cas-booleans-regexp nil)
  (setq cas-meta-functions-regexp nil)
  (setq cas-characters-regexp nil)
  (setq telemac-module-set nil)

  ;; (use-local-map telemac-mode-map)
))

(provide 'telemac-mode)
