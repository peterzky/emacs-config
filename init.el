(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

(add-hook 'after-init-hook #'(lambda ()
                               (setq gc-cons-threshold 800000)))

(if (fboundp 'menu-bar-mode)
    (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode)
    (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode)
    (scroll-bar-mode -1))

(when (version< emacs-version "26.3")
  (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"))

(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives
      '(("gnu" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
	("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
(unless package--initialized (package-initialize))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t)

(setq-default cursor-type 'bar)
(setq inhibit-startup-screen t)
(setq initial-scratch-message "")
(setq-default frame-title-format '("%b"))
(setq ring-bell-function 'ignore)
(fset 'yes-or-no-p 'y-or-n-p)
(show-paren-mode 1)
(setq linum-format "%4d ")
(delete-selection-mode 1)
(global-auto-revert-mode t)

(add-hook 'before-save-hook
	  'delete-trailing-whitespace)

(defun sanemacs/backward-kill-word ()
  (interactive "*")
  (push-mark)
  (backward-word)
  (delete-region (point) (mark)))

(global-set-key [mouse-3] 'mouse-popup-menubar-stuff)
(global-set-key (kbd "M-DEL") 'sanemacs/backward-kill-word)
(global-set-key (kbd "C-DEL") 'sanemacs/backward-kill-word)

(setq custom-file "~/.emacs.d/custom.el")
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))

(load custom-file nil t)

(defconst emacs-tmp-dir
  (expand-file-name
   (format "emacs%d"
	   (user-uid))
   temporary-file-directory))
(setq
 backup-by-copying t
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t
 auto-save-list-file-prefix emacs-tmp-dir
 auto-save-file-name-transforms `((".*" ,emacs-tmp-dir t))
 backup-directory-alist `((".*" . ,emacs-tmp-dir)))

(setq create-lockfiles nil)

(if (not custom-enabled-themes)
    (load-theme 'wombat t))

(defun reload-config ()
  (interactive)
  (load-file (concat user-emacs-directory "init.el")))


(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package orderless
  :ensure t
  :init
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
	 ("M-i" . consult-imenu)
	 ("M-s e" . consult-flymake)
	 ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)
         ("C-M-#" . consult-register))
  :init
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
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

(use-package embark
  :ensure t
  :init
  (setq embark-indicators
	'(embark-minimal-indicator
	  embark-highlight-indicator
	  embark-isearch-highlight-indicator))
  :bind (("C-." . embark-act)
	 ("M-." . embark-dwim)))

(use-package corfu
  :custom
  (corfu-auto t)
  :init
  (corfu-global-mode))

(use-package embark-consult
  :ensure t
  :after (embark consult))


(use-package magit
  :ensure t
  :diminish auto-revert-mode
  :bind ("C-x g" . magit-status)
  :config
  (setq magit-auto-revert-mode t)
  (setq magit-auto-revert-immediately t))


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

(use-package grip-mode
  :ensure t)

(use-package direnv
  :ensure t
  :config
  (direnv-mode))
