;; todo: more bedrock

(tool-bar-mode 0)

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

(global-set-key (kbd "M-s") 'save-buffer)

(with-eval-after-load 'package
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))

(use-package solarized-theme
  :ensure t
  :config
  (load-theme 'solarized-light t))

(use-package which-key
  :ensure t
  :config
  (setq which-key-idle-delay 0.25)
  (which-key-mode))

(use-package evil
  :ensure t
  :init
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-redo)
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode))

(use-package key-chord
  :ensure t
  :init
  (key-chord-define evil-insert-state-map "jk" 'evil-normal-state)
  :config
  (key-chord-mode))

(use-package treemacs
  :ensure t
  :defer t
  :bind
  (:map global-map
	("C-x t t" . treemacs)))

(use-package treemacs-evil
  :ensure t
  :after (treemacs evil))

(use-package rustic
  :ensure t
  :config
  (setq rustic-format-on-save t))

(use-package dhall-mode
  :ensure t
  :config
  (setq
   dhall-format-arguments (\` ("--ascii"))
   dhall-use-header-line nil))

(use-package company
  :ensure t
  :custom
  (company-idle-delay 0.1)
  :bind
  (:map company-active-map
	("C-n" . company-select-next)
	("C-p" . company-select-previous)))

(use-package flycheck
  :ensure t)

(use-package lsp-mode
  :ensure t
  :commands lsp
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  ; (add-to-list 'lsp-language-id-configuration '(".*\\.ts$" . "deno"))
  :hook ((lsp-mode . lsp-enable-which-key-integration)
	 (lsp-mode . lsp-diagnostics-mode)
	 (dhall-mode . lsp)
	 (typescript-ts-mode . lsp))
  :commands lsp)

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :hook ((lsp-mode-hook . lsp-ui-mode)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(company rustic solarized-theme treemacs-evil treemacs key-chord lsp-ui lsp-mode dhall-mode evil which-key)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-tooltip-selection ((t (:background "LightBlue1" :weight bold)))))
