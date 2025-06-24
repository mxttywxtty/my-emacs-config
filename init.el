(setq inhibit-startup-screen t) ;; disable default splash
(setq initial-scratch-message
      ";; Welcome to Emacs, fellow vibe coder!")

;; You will most likely need to adjust this font size for your system
(defvar efs/default-font-size 120)
(defvar efs/default-variable-font-size 130)

;; Make frame transparancy overridable
(defvar efs/frame-transparency '(100 . 100))

(server-start)

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'package)
(add-to-list 'package-archives
             '(("melpa" . "https://melpa.org/packages/")
	       ("nongnu" . "https://elpa.nongnu.org/nongnu/")
	       ("elpa" . "https://elpa.gnu.org/packages")))

(setq use-package-always-ensure t)

(scroll-bar-mode -1) 	; Disable visible scrollbar
(tool-bar-mode -1) 	; Disable the toolbar
(tooltip-mode -1) 	; Disable tooltips
(set-fringe-mode 10) 	; Give some breathing room

(menu-bar-mode -1) 	; Disable the menu bar

;; Set up the visible bell
(setq visible-bell t)

(column-number-mode)
(global-display-line-numbers-mode t)
(setq display-line-numbers 'relative)

;; Set frame transparancy
(set-frame-parameter (selected-frame) 'alpha efs/frame-transparency)
(add-to-list 'default-frame-alist `(alpha . ,efs/frame-transparency))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(use-package general
  :config
  (general-create-definer rune/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (rune/leader-keys
    "t"  '(:ignore t :which-key "toggles")
    "tt" '(counsel-load-theme :which-key "choose theme")))

(use-package org :load-path "~/.emacs.d/elpa/org-mode/lisp/")

(with-eval-after-load 'org
  ;; Increase preview width
  (setq org-latex-preview-appearance-options
	'(:page-width 0.8
	  :foreground "white"))

  (setq org-format-latex-options
	'(:scale 1.8))
  
  ;; Use dvisvgm to generate previews (optional, it's the default)
  (setq org-latex-preview-process-default 'dvisvgm)

  ;; Enable auto-mode for live previews
  (add-hook 'org-mode-hook #'org-latex-preview-auto-mode)

  ;; Optional: disable auto-preview on navigation commands
  (setq org-latex-preview-auto-ignored-commands
        '(next-line previous-line mwheel-scroll
                    scroll-up-command scroll-down-command))

  ;; Enable consistent equation numbering
  (setq org-latex-preview-numbered t)

  ;; Turn on live previews
  (setq org-latex-preview-live t)

  ;; Reduce debounce time for live preview updates
  (setq org-latex-preview-live-debounce 0.25))

(setq
 gptel-model 'qwen2.5:7b-instruct
 gptel-backend (gptel-make-ollama "Ollama"
                 :host "localhost:11434"
                 :stream t
                 :models '(qwen2.5:7b-instruct)))

(use-package evil
  :init
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Define your preferred fonts
(defvar efs/font-default "Iosevka Comfy")
(defvar efs/font-fixed-pitch "Iosevka Comfy")
(defvar efs/font-variable-pitch "Merriweather")

;; Safety check for installed fonts
(defun efs/font-installed-p (font-name)
  "Check if a FONT-NAME is available on the system."
  (find-font (font-spec :name font-name)))

;; Apply fonts only if available
(when (efs/font-installed-p efs/font-default)
  (set-face-attribute 'default nil
                      :font efs/font-default
                      :height efs/default-font-size))

(when (efs/font-installed-p efs/font-fixed-pitch)
  (set-face-attribute 'fixed-pitch nil
                      :font efs/font-fixed-pitch
                      :height efs/default-font-size))

(when (efs/font-installed-p efs/font-variable-pitch)
  (set-face-attribute 'variable-pitch nil
                      :font efs/font-variable-pitch
                      :height efs/default-variable-font-size
                      :weight 'regular))

;; Optional: Customize bold and italic faces
(when (efs/font-installed-p efs/font-default)
  (set-face-attribute 'bold nil
                      :weight 'bold
                      :family efs/font-default)
  (set-face-attribute 'italic nil
                      :slant 'italic
                      :family efs/font-variable-pitch))  ;; Italics use variable-pitch for a softer look

;; Optional: Use variable-pitch mode in Org Mode
(add-hook 'org-mode-hook #'variable-pitch-mode)

(use-package doom-themes
  :ensure t
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :config
  (load-theme 'doom-one-light t)

 ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (nerd-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package auctex
  :defer t
  :hook ((LaTeX-mode . TeX-PDF-mode))
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-save-query nil)
  (TeX-view-program-selection '((output-pdf "PDF Tools")))
  (TeX-source-correlate-mode t))

(use-package pdf-tools
  :config
  (pdf-tools-install))

(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook ((python-mode c++-mode) . lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (setq lsp-auto-guess-root t
        lsp-log-io nil
        lsp-restart 'auto-restart
        lsp-enable-symbol-highlighting nil
        lsp-enable-on-type-formatting nil
        lsp-signature-auto-activate nil
        lsp-signature-render-documentation nil
        lsp-eldoc-hook nil
        lsp-modeline-code-actions-enable nil
        lsp-modeline-diagnostics-enable nil
        lsp-headerline-breadcrumb-enable nil
        lsp-semantic-tokens-enable nil
        lsp-enable-folding nil
        lsp-enable-imenu nil
        lsp-enable-snippet nil
        read-process-output-max (* 1024 1024)
        lsp-idle-delay 0.5)
  (lsp-enable-which-key-integration t))

(use-package lsp-pyright
  :if (executable-find "python3")
  :hook (python-mode . (lambda ()
                         (require 'lsp-pyright)
                         (setq lsp-pyright-python-executable-cmd "python3")
                         (lsp-deferred))))

(use-package lsp-ui
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-doc-enable nil)
  (setq lsp-ui-doc-header t)
  (setq lsp-ui-doc-include-signature t)
  (setq lsp-ui-doc-border (face-foreground 'default))
  (setq lsp-ui-sideline-show-code-actions t)
  (setq lsp-ui-sideline-delay 0.05))

(use-package lsp-ivy)

(use-package dap-mode
  ;; Uncomment the config below if you want all UI panes to be hidden by default!
  ;; :custom
  ;; (lsp-enable-dap-auto-configure nil)
  ;; :config
  ;; (dap-ui-mode 1)

  :config
  ;; Set up Node debugging
  (require 'dap-node)
  (dap-node-setup) ;; Automatically installs Node debug adapter if needed
  
  ;; Bind `C-c l d` to `dap-hydra` for easy access
  (general-define-key
    :keymaps 'lsp-mode-map
    :prefix lsp-keymap-prefix
    "d" '(dap-hydra t :wk "debugger")))

(use-package python-mode
  :ensure t
  :hook (python-mode . lsp-deferred)
  :custom
  (python-shell-interpreter "python3")
  (dap-python-executable "python3")
  (dap-python-debugger 'debugpy)
  :config
  (require 'dap-python))

(use-package pyvenv
  :config
  (pyvenv-mode 1))

(use-package company
  :after lsp-mode
  :hook ((lsp-mode . company-mode)
  	(company-mode . yas-minor-mode))
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection))
  	(:map lsp-mode-map
	      ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0)
  (setq company-backends '((company-capf company-files company-yasnippet))))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package yasnippet
  :hook (prog-mode . yas-minor-mode)
  :config
  (yas-reload-all))

(use-package yasnippet-snippets
  :after yasnippet)

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/projects")
    (setq projectile-project-search-path '("~/projects")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; TODO: Make sure to configure a GitHub token before using this package
;; (use-package forge)

(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package vterm
  :commands vterm
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")
  (setq vterm-max-scrollback 10000))

(use-package dired
  :ensure nil  ;; it's built-in
  :commands (dired dired-jump)
  :hook ((dired-mode . dired-omit-mode))
  :bind (("C-x C-j" . dired-jump))
  :custom
  (dired-listing-switches "-agho --group-directories-first")
  (dired-omit-files "^\\..+$")
  :config
  (with-eval-after-load 'evil-collection
    (evil-collection-define-key 'normal 'dired-mode-map
      "h" 'dired-single-up-directory
      "l" 'dired-single-buffer
      "H" 'dired-omit-mode)))

(use-package dired-open
  :after dired
  :config
  (setq dired-open-extensions '(("png" . "xdg-open")
				("mkv" . "mpv"))))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(jetbrains-darcula-theme org-roam gptel org org-latex-preview org-mode))
 '(package-vc-selected-packages
   '((org-mode :url "https://code.tecosaur.net/tec/org-mode" :branch "dev"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
