;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
;; I suggest to keep these comment lines, too
;; below you will see customization automatically added by Emacs

;; This is a workaround to get the elpa directory which is created by nix
(when (string= (system-name) "nixos")
  (progn
    (setq nix-elpa-path (concat (replace-regexp-in-string "\r?\n$" "" (shell-command-to-string "nix-store -q --requisites $(readlink $(readlink $(which emacs))) | grep emacs-packages-deps")) "/share/emacs/site-lisp/elpa/"))
    (let ((default-directory nix-elpa-path))
      (normal-top-level-add-subdirs-to-load-path))
    (add-to-list 'package-directory-list nix-elpa-path)

    (dolist (theme-path (directory-files nix-elpa-path nil "theme"))
      (add-to-list 'custom-theme-load-path (concat nix-elpa-path "/" theme-path))
      )
    )
  )

;; Org and Org-roam
(require 'org)
(setq org-log-done 'time)
(setq org-agenda-files (list "/sharedfolders/Syncthing/Dokumente/Notizen/Allgemein.org"
			     "/sharedfolders/Syncthing/Dokumente/Notizen/journals"))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 ;'(org-agenda-files
 ;  (quote
 ;   ("/sharedfolders/Syncthing/Dokumente/Notizen/Allgemein.org" "/sharedfolders/Syncthing/Dokumente/Notizen/journals/2022-04-24.org" "/sharedfolders/Syncthing/Dokumente/Notizen/journals/2022-04-16.org" "/sharedfolders/Syncthing/Dokumente/Notizen/journals/2022-04-14.org" "/sharedfolders/Syncthing/Dokumente/Notizen/journals/2022-04-13.org" "/sharedfolders/Syncthing/Dokumente/Notizen/journals/2022-04-10.org" "/sharedfolders/Syncthing/Dokumente/Notizen/journals/2022-04-09.org")))
 '(org-directory "/sharedfolders/Syncthing/Dokumente/Notizen/journals/")
 '(package-selected-packages
   (quote
    (f olivetti org-journal transient magit quelpa counsel emacsql-sqlite3 org-roam one-themes)))
 '(safe-local-variable-values
   (quote
    ((eval progn
	   (setq-local org-roam-directory "/sharedfolders/Syncthing/Dokumente/Notizen")
	   (setq-local org-roam-db-location "/sharedfolders/Syncthing/Dokumente/Notizen/org-roam.db")
	   (setq-local org-roam-file-exclude-regexp
		       (rx ".stversions"))
	   (setq-local org-roam-capture-templates
		       (quote
			(("d" "default" plain "%?"
			  (function org-roam-capture--get-point)
			  "%?" :target
			  (file+head "pages/${slug}.org" "#+title: ${title}
")
			  :unnarrowed t)))))))))



;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
;; I suggest to keep these comment lines, too
;; below you will see customization automatically added by Emacs


;;; Org-roam
;;; Tell Emacs to start org-roam-mode when Emacs starts
(add-hook 'after-init-hook 'org-roam-setup)

(setq org-roam-directory "/sharedfolders/Syncthing/Dokumente/Notizen")
(setq org-roam-db-location "/sharedfolders/Syncthing/Dokumente/Notizen/org-roam.db")
(setq org-roam-v2-ack t)

(org-roam-db-autosync-mode)
(setq org-roam-completion-everywhere t)


;;; Define key bindings for Org-roam
(require 'org-roam-dailies)
(setq org-roam-dailies-directory "journals/")

;; Org-journal
(setq org-journal-dir "/sharedfolders/Syncthing/Dokumente/Notizen/journals/")
(setq org-journal-file-format "%Y-%m-%d.org")
(setq org-journal-date-format "%A, %d.%m.%Y")
(setq org-journal-time-prefix "* ")
(setq org-journal-date-prefix "#+TITLE: ")

;(setq org-journal-enable-agenda-integration t
(setq org-icalendar-include-todo 'all
      org-icalendar-combined-agenda-file "/sharedfolders/Syncthing/Dokumente/Notizen/journals/org-journal.ics")

(setq org-icalendar-alarm-time 2880)
(setq org-icalendar-categories '(all-tags all-tags))
(setq org-icalendar-use-deadline '(event-if-not-todo event-if-todo-not-done todo-due))
(setq org-icalendar-use-scheduled '(event-if-not-todo event-if-todo-not-done todo-start))


(defun latest-file-version (dir prefix)
  "Get the latest version of files in DIR starting with PREFIX.
Only filenames in DIR with the form PREFIX-version are
considered, where the version portion of the filename must have
valid version syntax as specified for `version-to-list'. Raise an
error if no filenames in DIR start with PREFIX or if no valid
matching versioned filenames are found."
  (let* ((vsn-regex (concat "^" prefix "-\\(.+\\)$"))
         (vsn-entries
          (seq-reduce
           #'(lambda (acc s)
               (if (string-match vsn-regex s)
                   (let* ((m (match-string 1 s))
                          (vsn (condition-case nil
                                   (version-to-list m)
                                 (error nil))))
                     (if vsn
                         (cons (cons m s) acc)
                       acc))
                 acc)) 
           (directory-files dir nil nil t) nil)))
    (if vsn-entries
        (concat (file-name-as-directory dir)
          (cdar (sort vsn-entries
                      #'(lambda (v1 v2)
                          (version<= (car v2) (car v1))))))
      (error "No valid versioned filenames found in %s with prefix \"%s-\""
             dir prefix))))



;;(add-to-list 'load-path "~/.emacs.d/elpa/org-journal-20220103.829")
;(let ((default-directory  "~/.emacs.d/elpa/"))
;  (normal-top-level-add-subdirs-to-load-path))
;(add-to-list 'load-path (latest-file-version "~/.emacs.d/elpa" "org-journal"))
;(add-to-list 'load-path (latest-file-version "~/.emacs.d/elpa" "org-roam"))
;(dolist (pkg '("org-journal" "dash" "f" "s" "emacsql" "emacsql-sqlite" "magit-section" "org-roam"))
;  (add-to-list 'load-path (latest-file-version "~/.emacs.d/elpa" pkg)))
;; Org-journal
;(setq org-journal-dir "/sharedfolders/Syncthing/Dokumente/Notizen/journals/")
;(setq org-journal-file-format "%Y-%m-%d.org")
;(setq org-journal-date-format "%A, %d.%m.%Y")
;(setq org-journal-time-prefix "* ")
;(setq org-journal-date-prefix "#+TITLE: ")

;(setq org-journal-enable-agenda-integration t
;      org-icalendar-store-UID t
;      org-icalendar-include-todo 'all
;      org-icalendar-combined-agenda-file "/sharedfolders/Syncthing/Dokumente/Notizen/journals/org-journal.ics")

;(setq org-icalendar-alarm-time 2880)
;(setq org-icalendar-categories '(all-tags all-tags))
;(setq org-icalendar-use-deadline '(event-if-not-todo event-if-todo-not-done todo-due))
;(setq org-icalendar-use-scheduled '(event-if-not-todo event-if-todo-not-done todo-start))

;(require 'org-journal)
;;(org-journal-update-org-agenda-files) ; put future entries on the agenda

;;; Org-roam (this corresponds to .dir-locals in /sharedfolders/Syncthing/Dokumente/Notizen)
;(require 'org)
;(require 'org-roam)
;(setq org-roam-directory "/sharedfolders/Syncthing/Dokumente/Notizen")
;(org-roam-db-autosync-mode)

;(setq org-id-extra-files (find-lisp-find-files org-roam-directory "\.org$"))
(setq org-id-extra-files (org-roam--list-files org-roam-directory))

;; avoid interactive prompts if UIDs are created
(defadvice org-icalendar-create-uid (after org-icalendar-create-uid-after activate)
  (save-buffer))

(org-icalendar-combine-agenda-files)  ; export the ICS file
(save-buffers-kill-emacs t)           ; save all modified files and exit
