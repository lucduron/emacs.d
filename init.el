; Author: Luc Duron
; Recommanded Emacs version: 24.4

;;; LOAD GLOBAL PACKAGES
(load-library "iso-transl") ; write character with circumflex (ïîô...)

;;; LOAD DOWNLOADED/INSTALLED PACKAGES WITH SOME PERSONAL CONFIGURATIONS
(add-to-list 'load-path "~/.emacs.d/my-packages")

;; TransposeFrame : http://www.emacswiki.org/emacs/TransposeFrame
(require 'transpose-frame)
(global-set-key (kbd "M-t") 'transpose-frame)
(global-set-key (kbd "M-r") 'rotate-frame-clockwise)
(global-set-key (kbd "M-R") 'rotate-frame)

;; WindMove : http://www.emacswiki.org/emacs/WindMove
(require 'windmove)
; Quick move focus from frame with M-<up>/{<up>,<down>,<left>,<right>}
(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings 'meta)) ; FIXME: conflict if Markdow-mode

;; RedoPlus : http://www.emacswiki.org/emacs/RedoPlus
(require 'redo+)
(global-set-key (kbd "C-8") 'redo)

;; Auto Complete Mode
(add-to-list 'load-path "~/.emacs.d/auto-complete")
(require 'auto-complete)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/auto-complete/dict")
(require 'auto-complete-config)
(ac-config-default)

;; CSV Mode: read tables
(add-to-list 'auto-mode-alist '("\\.[Cc][Ss][Vv]\\'" . csv-mode))
(autoload 'csv-mode "csv-mode"
  "Major mode for editing comma-separated value files." t)

;; Markdown
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)

;; Lilypond
; Lilypond should be installed?
(add-to-list 'auto-mode-alist '("\\.ly\\'" . LilyPond-mode))
(autoload 'LilyPond-mode "lilypond-mode")

;; git-gutter
; Highligh changes in the left margin
(require 'git-gutter)
(global-git-gutter-mode +1)

;;;; APPARENCE/DISPLAY/BEHAVIOUR

(add-hook 'emacs-startup-hook 'transpose-frame) ; Startup with side-by-side window (if more than one file is opened)
(setq inhibit-startup-message t) ; Disable startup message
(setq large-file-warning-threshold nil) ; Avoid warning if file is too large
(setq column-number-mode t) ; Display column number
(require 'sunburst-theme)

;; Different behaviour if GUI is launched
(if (display-graphic-p)
  (progn ;; Emacs as GUI
    (tool-bar-mode -1) ; Hide tool bar
    ;(load-theme 'misterioso) ; Color theme
    (set-face-attribute 'default nil :height 105) ; change font-size (defaut around 110?)
  ) ;; else (optional) no window/X
    (menu-bar-mode -1) ; Hide menu bar
  )

(custom-set-variables '(show-trailing-whitespace t)) ;FIXME: only in non-auto bufferS
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

;;;; MODE SPECIFICATIONS

;; Fortran
; These commands overwrite the one by default (`fortran.el` in installation folder)
(setq fortran-line-length 132) ; in coherance with compiler option
(setq fortran-comment-indent-style nil) ; forces comment lines not to be touched
(setq fortran-continuation-string "&")
(setq fortran-comment-line-start "!") ; default="C"
(setq fortran-comment-region "!") ; default="c$$$"
; Indentation
(setq fortran-do-indent 2)
(setq fortran-if-indent 2)
(setq fortran-structure-indent 2)

;; My correction for fortran mode (fix bug to jump to next fortran subprogram)
(eval-after-load "fortran"
  '(global-set-key (kbd "C-M-e") 'fortran-end-of-subprogram)
)

;;;; KEY BINDINGS

;; Change frame/window size
(global-set-key (kbd "M-\"") 'enlarge-window-horizontally)
(global-set-key (kbd "M-é") 'enlarge-window)
;(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
;(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
;(global-set-key (kbd "S-C-<down>") 'shrink-window)
;(global-set-key (kbd "S-C-<up>") 'enlarge-window)

(global-set-key (kbd "C-x O") 'previous-multiframe-window) ; opposite function of C-x o

;; List buffer in active window (invoke `buffer-menu` instead of `list-buffer`)
(global-set-key "\C-x\C-b" 'buffer-menu)

;; Make C-c C-c behave like C-u C-c C-c in Python mode
(require 'python)
(define-key python-mode-map (kbd "C-c C-c")
  (lambda () (interactive) (python-shell-send-buffer t)))

;;;; FUNCTIONS

(defun tf-toggle-show-trailing-whitespace ()
  "Toggle show-trailing-whitespace between t and nil"
  (interactive)
  (setq show-trailing-whitespace (not show-trailing-whitespace)))
