; Author: Luc Duron
; Recommanded Emacs version: 24.5
;
; sunburst-theme requires a 256 color terminal (try to change the settings of your terminal software)

;;;
;;; GLOBAL
;;;

;; Packages
; Emacs 24 bundled a package system called ELPA (emacs lisp package archive).
; It lets you install and auto-update and manage emacs packages.
(when (>= emacs-major-version 24)
  (require 'package)
  (package-initialize)
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
  )
; Used to install jedi (and its dependances)

;;; load global packages
(load-library "iso-transl") ; write character with circumflex (ïîô...)

;;; load downloaded/installed packages with some personal configurations
(add-to-list 'load-path "~/.emacs.d/my-packages")

;;;
;;; REQUIRED PACKAGES
;;;
(add-to-list 'load-path "~/.emacs.d/my-packages/dired+")
(require 'dired+) ;; installed with melpa
(setq dired-listing-switches "-alh") ; human readable (default is -al)

;; TransposeFrame - http://www.emacswiki.org/emacs/TransposeFrame
(require 'transpose-frame)
(global-set-key (kbd "M-t") 'transpose-frame)
(global-set-key (kbd "M-r") 'rotate-frame-clockwise)
(global-set-key (kbd "M-R") 'rotate-frame)
(add-hook 'emacs-startup-hook 'transpose-frame) ; startup with side-by-side window (if more than one file is opened)

;; WindMove - http://www.emacswiki.org/emacs/WindMove
(require 'windmove)
; Quick move focus from frame with M-<up>/{<up>,<down>,<left>,<right>}
(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings 'meta)) ; FIXME: conflict if Markdow-mode

;; RedoPlus - http://www.emacswiki.org/emacs/RedoPlus
(require 'redo+)
(global-set-key (kbd "C-8") 'redo)

;; AutoComplete mode - http://emacswiki.org/emacs/AutoComplete
(add-to-list 'load-path "~/.emacs.d/auto-complete")
(require 'auto-complete)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/auto-complete/dict")
(require 'auto-complete-config)
(ac-config-default)

;; CSV Mode - diplay more readable tables
(add-to-list 'auto-mode-alist '("\\.csv\\'" . csv-mode))
(autoload 'csv-mode "csv-mode"
  "Major mode for editing comma-separated value files." t)

;; markdown (is based on text-mode)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)

(setq markdown-command "~/.emacs.d/my-packages/markdown/markdown_complete.sh") ; Add encoding (before html body) for `markdown-preview`
(setq markdown-command-needs-filename t) ; Hack to use `markdown-preview` with arguments and avoid stdin (FIXME: consider stdin in markdown_complete.sh and remove this hack)

;; php-mode
; file php-mode.el downloaded from https://sourceforge.net/projects/php-mode/files/latest/download
(autoload 'php-mode "php-mode" "Major mode for editing php code." t)
(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))
(add-to-list 'auto-mode-alist '("\\.inc$" . php-mode))

;; Lilypond
; Lilypond should be installed?
(add-to-list 'auto-mode-alist '("\\.ly\\'" . LilyPond-mode))
(autoload 'LilyPond-mode "lilypond-mode")

;; git-gutter - Highligh changes in the left margin
(require 'git-gutter)
(global-git-gutter-mode +1)

;; Telemac CAS (syntax and keywords)
(add-to-list 'auto-mode-alist '("\\.cas\\'" . telemac-mode))
(autoload 'telemac-mode "telemac-mode"
  "Major mode for editing telemac cas files" t)

;;;
;;; APPARENCE/DISPLAY/BEHAVIOUR
;;;

(setq inhibit-startup-message t) ; Disable startup message
(setq large-file-warning-threshold nil) ; Avoid warning if file is too large
(setq column-number-mode t) ; Display column number
(require 'sunburst-theme)

;; Different behaviour if GUI is launched
(if (display-graphic-p)
  (progn
    ;; Emacs as GUI
    (tool-bar-mode -1) ; Hide tool bar
    ;(load-theme 'misterioso) ; Color theme
    (set-face-attribute 'default nil :height 105) ; change font-size (defaut around 110?)
  ) ;; else (optional) no window/X
    (menu-bar-mode -1) ; Hide menu bar
  )

 ;FIXME: only in non-auto bufferS
(show-paren-mode 1) ; Highlight matching pairs of parentheses and other characters

(setq make-backup-files nil) ; Do not make *~ backup files

;; Ignoring Emacs auto buffers in moving to previous/next buffer
(defun emacs-buffer-p (name)
  (string-match-p "\\*.*\\*" name))

(defun next-non-emacs-buffer (&optional original)
  "Similar to next-buffer, but ignores emacs buffer such as *scratch*, *messages* etc."
  (interactive)
  (let ((tmp-orig (or original (buffer-name))))
    (next-buffer)
    (if (and
      (not (eq (buffer-name) tmp-orig))
      (emacs-buffer-p (buffer-name)))
      (next-non-emacs-buffer tmp-orig))))

(defun previous-non-emacs-buffer (&optional original)
  "Similar to previous-buffer, but ignores emacs buffer such as *scratch*, *messages* etc."
  (interactive)
  (let ((tmp-orig (or original (buffer-name))))
    (previous-buffer)
    (if (and
      (not (eq (buffer-name) tmp-orig))
      (emacs-buffer-p (buffer-name)))
      (previous-non-emacs-buffer tmp-orig))))

(global-set-key [remap next-buffer] 'next-non-emacs-buffer)
(global-set-key [remap previous-buffer] 'previous-non-emacs-buffer)

;;;; KEY BINDINGS

;; Change frame/window size
(global-set-key (kbd "M-\"") 'enlarge-window-horizontally)
(global-set-key (kbd "M-é") 'enlarge-window)
;(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
;(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
;(global-set-key (kbd "S-C-<down>") 'shrink-window)
;(global-set-key (kbd "S-C-<up>") 'enlarge-window)

(global-set-key (kbd "C-x O") 'previous-multiframe-window) ; opposite function of C-x o

;; Make C-c C-c behave like C-u C-c C-c in Python mode
(require 'python)
(define-key python-mode-map (kbd "C-c C-c")
  (lambda () (interactive) (python-shell-send-buffer t)))

;;;; FUNCTIONS

(defun toggle-show-trailing-whitespace ()
  "Toggle show-trailing-whitespace between t and nil"
  (interactive)
  (setq show-trailing-whitespace (not show-trailing-whitespace)))

;;;
;;; HOOK
;;;

;; text-mode
(add-hook 'text-mode-hook
  '(lambda ()
     (setq word-wrap t)
     ))

;; Fortran
; These commands overwrite those from `fortran.el` (in installation folder)
(add-hook 'fortran-mode-hook
  '(lambda ()
    (fortran-line-length 132 t) ; in coherance with compiler option
    (setq fortran-comment-indent-style nil) ; forces comment lines not to be touched
    (setq fortran-continuation-string "&")
    (setq fortran-comment-line-start "!") ; default="C"
    (setq fortran-comment-region "!") ; default="c$$$"

    ; Indentation
    (setq fortran-do-indent 2)
    (setq fortran-if-indent 2)
    (setq fortran-structure-indent 2)

    ;; Correction for Fortran mode (fix bug to jump to next fortran subprogram)
    (eval-after-load "fortran" '(global-set-key (kbd "C-M-e") 'fortran-end-of-subprogram))
    ))

;; Python
; activate jedi (popup function description)
;; (add-hook 'python-mode-hook 'jedi:setup)
;; (setq jedi:setup-keys t)       ; optional
;; (setq jedi:complete-on-dot t)  ; optional
;; (setq jedi:server-args '("--log-traceback"))


;; Ibuffer

(setq ibuffer-saved-filter-groups
  (quote (("default"
         ("emacs" (or
  		 (name . "^\\*scratch\\*$")
  		 (name . "^\\*Messages\\*$")
  		 (name . "^\\*Completions\\*$")))
    ("Help" (or (mode . Man-mode)
      (mode . woman-mode)
      (mode . Info-mode)
      (mode . Help-mode)
      (mode . help-mode)))
         ("shell" (or
  		 (name . "^\\*shell\\*$")
  		 (name . "^\\*eshell\\*$")
      (name . "^\\*Python")))
    ("dired" (mode . dired-mode))
	 ))))

(add-hook 'ibuffer-mode-hook
  (lambda ()
    (ibuffer-switch-to-saved-filter-groups "default")))

(global-set-key (kbd "C-x C-b") 'ibuffer)
;; List buffer in active window (invoke `buffer-menu` instead of `list-buffer`)
;; (global-set-key "\C-x\C-b" 'buffer-menu)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(indent-tabs-mode nil)
 '(show-trailing-whitespace t))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; (require 'python-django)

(setq x-select-enable-clipboard t)
(setq interprogram-paste-function 'x-cut-buffer-or-selection-value)

(if (eq system-type 'cygwin)
    (message "Free as in Freedom")
    (require 'windows-path)
    (windows-path-activate)
)

; org-mode
(require 'org)
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)



(defun flush-blank-lines ()
  "Removes all blank lines from buffer or region"
  (interactive)
  (save-excursion
    (let (min max)
      (if (equal (region-active-p) nil)
        (mark-whole-buffer))
    (setq min (region-beginning) max (region-end))
    (flush-lines "^ *$" min max t)
    )))


;; Make csv-separators for a single buffer => not working...
; M-: (make-local-variable 'csv-separators)
; M-: (setq csv-separators '("|" ";"))
