;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!
(defun load-if-exists (f)
  (if (file-exists-p (expand-file-name f))
      (load-file (expand-file-name f))))

(load-if-exists "~/.doom.d/.secrets.el")

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name gm/user
      user-mail-address gm/email)
;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;;(setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-tokyo-night)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/notes/")
(setq org-roam-directory "~/notes/org-roam/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;;
(defun gm/add-file-keybinding (key file &optional desc)
  (let ((key key)
        (file file)
        (desc desc))
    (map! :desc (or desc file)
          key
          (lambda () (interactive) (find-file file)))))

(gm/add-file-keybinding "C-c g t" "~/notes/todo.org")
(gm/add-file-keybinding "C-c g p" "~/notes/projects.org")
(gm/add-file-keybinding "C-c g w" "~/notes/work.org")

;; Fix dired opening a ton of buffers
(setf dired-kill-when-opening-new-dired-buffer t)

;; Fix bug https://discourse.doomemacs.org/t/recentf-cleanup-logs-a-lot-of-error-messages/3273/5
(after! tramp (advice-add 'doom--recentf-file-truename-fn :override
                          (defun my-recent-truename (file &rest _args)
                            (if (or (not (file-remote-p file)) (equal "sudo" (file-remote-p file 'method)))
                                (abbreviate-file-name (file-truename (tramp-file-local-name file)))
                              file))))

;; Accept completion from copilot and fallback to company
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)))


;; Create a new Git branch based on format: <name>/<shortcut-story>/<description>
(defun gm/create-shortcut-git-branch (source-branch shortcut-story description)
  "Create a new Git branch based on format: <name>/<shortcut-story>/<description>"
  (interactive "sSource branch: \nsShortcut story: \nsDescription: ")
  (magit-with-toplevel
   (let* ((template-ref (concat "refs/heads/" source-branch))
          (full-name (replace-regexp-in-string " " "" (downcase gm/user)))
          (new-branch-name (format "%s/%s/%s" full-name shortcut-story description))
          (git-command (format "git checkout -b %s %s" new-branch-name template-ref)))
     (shell-command git-command)
     (magit-refresh)
     (message "Created branch '%s' based on template branch '%s'" new-branch-name template-branch))))
