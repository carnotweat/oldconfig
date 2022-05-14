;; Adds melpa package access
;; Requires tweaking for emacs 22
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

  ;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))
(use-package org-journal
  :ensure t
  :defer t
  :init
  ;; Change default prefix key; needs to be set before loading org-journal
;;  (setq org-journal-prefix-key "C-c j ")
  :config
  (setq org-journal-dir "~/org/journal/"
        ;;org-journal-date-format "%A, %d %B %Y"
	))

;; ;; loads the preferred theme (must be installed already)
;; ;; to install this theme check here: https://github.com/purcell/color-theme-sanityinc-tomorrow
;; (load-theme sanityinc-tomorrow-night t)

;; Send all emacs backups to a specific folder. 
(setq backup-directory-alist '(("" . "~/emacs")))
(with-eval-after-load 'org
    (setq org-directory "~/org"))

;;(load-library "~/org")

(setq org-use-speed-commands t)
(setq org-capture-templates '(("j" "Journal" entry (file+olp+datetree "~/org/cpb.org") "* %? :journal:\n")))

(add-hook 'before-save-hook 'time-stamp)

