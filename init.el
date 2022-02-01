;; -*- lexical-binding: t; -*-
(setq custom-file (locate-user-emacs-file "custom.el"))

;; Set higher GC threshold for performance
(setq gc-cons-threshold (* 100 1024 1024))
;; Set higher IPC read threshold for applications like 'lsp-mode'
(setq read-process-output-max (* 1 1024 1024))

(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives
      '(("gnu"   . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
	    ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
(unless package--initialized (package-initialize))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(use-package emacs
  :custom
  (user-full-name "peterzky")
  (inhibit-startup-message t)
  (initial-scratch-message nil)
  (menu-bar-mode nil)
  (scroll-bar-mode nil)
  (tool-bar-mode nil)
  (display-line-numbers nil)
  (tab-width 4)
  (tab-always-indent 'complete)
  (indent-tabs-mode nil)
  (delete-selection-mode t)
  (kill-whole-line t)
  (save-interprogram-paste-before-kill t)
  (ring-bell-function 'ignore)
  (compilation-scroll-output t)
  (show-paren-mode nil)
  (major-mode 'text-mode)
  (backup-by-copying t)
  (auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))
  (delete-old-versions t)
  (kept-new-versions 3)
  (kept-old-versions 2)
  (version-control t)
  (bookmark-default-file "~/Sync/emacs/bookmark")
  (use-dialog-box nil)
  (help-window-select t)
  (vc-follow-symlinks "Follow link")
  (mouse-yank-at-point t)
  :bind
  (("<mouse-3>" . 'mouse-major-mode-menu)
   ("C-x C-b" . ibuffer)
   ("C-x k" . kill-this-buffer))
  :config
  (fset 'yes-or-no-p 'y-or-n-p)
  (prefer-coding-system 'utf-8)
  )

(add-to-list 'default-frame-alist '(alpha-background . 80))
(add-to-list 'default-frame-alist '(width . 90))
(add-to-list 'default-frame-alist '(height . 50))

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-vibrant t)
  (doom-themes-org-config))

(use-package rainbow-mode
  :ensure t)

(use-package org
  :custom
  (org-agenda-skip-deadline-if-done t)
  (org-agenda-skip-scheduled-if-done t)
  (org-agenda-start-with-log-mode t)
  (org-agenda-tags-todo-honor-ignore-options t)
  (org-agenda-todo-ignore-scheduled 'all)
  (org-agenda-window-setup 'current-window)
  (org-attach-auto-tag "attach")
  (org-attach-directory "attach/")
  (org-attach-store-link-p 'attached)
  (org-clock-clocked-in-display nil)
  (org-clock-out-remove-zero-time-clocks t)
  (org-confirm-babel-evaluate nil)
  (org-deadline-warning-days 5)
  (org-edit-src-content-indentation 0)
  (org-enforce-todo-dependencies nil)
  (org-footnote-define-inline t)
  (org-goto-interface 'outline-path-completion)
  (org-image-actual-width 600)
  (org-imenu-depth 5)
  (org-indirect-buffer-display 'current-window)
  (org-log-done 'time)
  (org-log-into-drawer t)
  (org-log-states-order-reversed nil)
  (org-src-fontify-natively t)
  (org-src-preserve-indentation t)
  (org-src-tab-acts-natively t)
  (org-src-window-setup 'current-window)
  (org-startup-folded t)
  (org-startup-indented t)
  (org-todo-keywords
   '((sequence "NEXT(n)" "INBOX(i)" "WAIT(w@/!)" "MAYBE(m)"  "|" "DONE(d)" "CANCELED(c@)")))
  (org-use-speed-commands t)
  :ensure t
  :bind (("C-c c" . org-capture)
         ("C-c a" . org-agenda)
         ("C-c l" . org-store-link))
  :config
  (when (file-exists-p "~/Sync/roam")
    (setq org-directory "~/Sync/emacs/org")
    (setq org-agenda-files (list "~/Sync/roam" "~/Sync/roam/daily")))
  )

(use-package org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
  (setq org-bullets-bullet-list '("●" "○")))

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(use-package savehist
  :init
  (savehist-mode))

(use-package consult
  :ensure t
  :bind (("M-s g" . consult-git-grep)
	     ("M-s l" . consult-line)
	     ("M-i"   . consult-imenu)
	     ("M-s e" . consult-flymake)
	     ("M-#"   . consult-register-load)
         ("M-'"   . consult-register-store)
         ("C-M-#" . consult-register))
  :init
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  ;; Use `consult-completion-in-region' if Vertico is enabled.
  ;; Otherwise use the default `completion--in-region' function.
  (setq completion-in-region-function
	    (lambda (&rest args)
          (apply (if vertico-mode
                     #'consult-completion-in-region
                   #'completion--in-region)
		         args)))
  :config
  (setq consult-project-root-function #'vc-root-dir))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet)

(use-package embark
  :ensure t
  :init
  (setq embark-indicators
	    '(embark-minimal-indicator
	      embark-highlight-indicator
	      embark-isearch-highlight-indicator))
  :bind (("C-." . embark-act)
	     ("M-." . embark-dwim)))

(use-package embark-consult
  :ensure t
  :after (embark consult))

(use-package company
  :ensure t
  :diminish company-mode
  :init
  (setq company-idel-delay 0.2)
  (setq company-backends '(company-capf))
  :bind ("M-<tab>" . company-other-backend)
  :config
  (global-company-mode))

(use-package company-tabnine
  :ensure t
  :after company
  :init
  (setq company-backends '(company-tabnine company-capf)))

(use-package smartparens
  :ensure t
  :diminish smartparens-mode
  :bind (:map smartparens-mode-map
              ("M-("             . sp-wrap-round)
              ("C-M-<backspace>" . sp-backward-unwrap-sexp)
              ("C-<right>"       . sp-forward-slurp-sexp)
              ("C-<left>"        . sp-forward-barf-sexp))

  :config
  ;; (setq sp-highlight-pair-overlay 'nil)
  (setq sp-ignore-modes-list
	    '(inferior-emacs-lisp-mode
	      emacs-lisp-mode))
  (require 'smartparens-config)
  (smartparens-global-mode t))

(use-package crux
  :ensure t
  :diminish t
  :bind (("C-c r"   . crux-rename-file-and-buffer)
	     ("C-c d"   . crux-duplicate-and-comment-current-line-or-region)
	     ("M-o"     . crux-other-window-or-switch-buffer)
	     ("C-x 4 t" . crux-transpose-windows))
  :config
  (crux-reopen-as-root-mode))

(use-package avy
  :ensure t
  :bind ("C-;" . avy-goto-char))

(use-package dired
  :init
  (setq dired-kill-when-opening-new-dired-buffer t)
  :hook (dired-mode . (lambda () (dired-hide-details-mode)))
  )

(use-package flymake
  :bind (:map flymake-mode-map
	          ("M-n" . flymake-goto-next-error)
	          ("M-p" . flymake-goto-prev-error))
  )

(use-package ibuffer-project
  :ensure t
  :after ibuffer
  :config
  (add-hook 'ibuffer-hook
            (lambda ()
              (setq ibuffer-filter-groups (ibuffer-project-generate-filter-groups))
              (unless (eq ibuffer-sorting-mode 'project-file-relative)
		        (ibuffer-do-sort-by-project-file-relative)))))

(use-package repeat
  :config
  (repeat-mode t))

(use-package project
  :config
  (setq project-switch-use-entire-map t))

(use-package magit
  :ensure t
  :diminish auto-revert-mode
  :bind ("C-x g" . magit-status)
  :config
  (setq magit-auto-revert-mode t)
  (setq magit-auto-revert-immediately t))

(use-package diff-hl
  :ensure t
  :config
  (global-diff-hl-mode)
  (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  )

(use-package ediff
  :custom
  (ediff-window-setup-function 'ediff-setup-windows-plain))

(use-package eglot
  :ensure t
  :init
  (setq eglot-stay-out-of '("company"))
  (setq eglot-autoshutdown t)
  ;; disable multiline eldoc, view doc with C-h .
  (setq eldoc-echo-area-use-multiline-p nil)
  :bind
  ("C-x l" . eglot)
  (:map eglot-mode-map
	    ("C-c C-r" . eglot-rename)
	    ("C-c C-f" . eglot-format)
	    ("C-c o" . eglot-code-actions))
  :commands eglot)

(use-package python
  :hook (python-mode . (lambda ()
			             (setq forward-sexp-function nil))))


(use-package haskell-mode
  :ensure t)

(use-package rust-mode
  :ensure t
  :config
  (setq rust-format-on-save t))

(use-package cmake-mode
  :ensure t)

(use-package nix-mode
  :ensure t
  :magic
  ("\.nix$" . nix-mode)
  :hook
  (nix-mode . eglot-ensure)
  :custom
  (nix-indent-function 'nix-indent-line))

(use-package direnv
  :ensure t
  :config
  (direnv-mode))

(use-package tramp
  :init
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

(use-package dockerfile-mode
  :ensure t)
(use-package docker-tramp
  :ensure t)

(use-package yaml-mode
  :ensure t)

(use-package meson-mode
  :ensure t)
