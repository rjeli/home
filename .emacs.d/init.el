;; Automatically reread from disk if the underlying file changes
(setopt auto-revert-avoid-polling t)

;; Make right-click do something sensible
(when (display-graphic-p)
  (context-menu-mode))

(setq auto-save-file-name-transforms
    '((".*" "~/.emacs.d/backup/" t)))
(setq backup-directory-alist
    '((".*" . "~/.emacs.d/backup")))

(setopt line-number-mode t)
(setopt column-number-mode t)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(setopt display-line-numbers-width 3)

(blink-cursor-mode -1)

(use-package which-key
  :ensure t
  :config
  (which-key-mode))

(use-package evil
  :ensure t
  :init
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-redo)
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode))
