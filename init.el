(add-to-list 'command-switch-alist
			 (cons "--live-safe-mode"
				   (lambda (switch)
					 nil)))

(setq live-safe-modep
	  (if (member "--live-safe-mode" command-line-args)
		  "debug-mode-on"
		nil))

(setq live-supported-emacsp t)

(when live-supported-emacsp
  ;; Store live base dirs, but respect user's choice of `live-root-dir'
  ;; when provided.
  (setq live-root-dir (if (boundp 'live-root-dir)
						  (file-name-as-directory live-root-dir)
						(if (file-exists-p (expand-file-name "manifest.el" user-emacs-directory))
							user-emacs-directory)
						(file-name-directory (or
											  load-file-name
											  buffer-file-name))))

  (setq
   live-tmp-dir		 (file-name-as-directory (concat live-root-dir "tmp"))
   live-etc-dir		 (file-name-as-directory (concat live-root-dir "etc"))
   live-pscratch-dir (file-name-as-directory (concat live-tmp-dir  "pscratch"))
   live-lib-dir		 (file-name-as-directory (concat live-root-dir "lib"))
   live-packs-dir	 (file-name-as-directory (concat live-root-dir "packs"))
   live-autosaves-dir(file-name-as-directory (concat live-tmp-dir  "autosaves"))
   live-backups-dir	 (file-name-as-directory (concat live-tmp-dir  "backups"))
   live-custom-dir	 (file-name-as-directory (concat live-etc-dir  "custom"))
   live-load-pack-dir nil
   live-disable-zone nil)

  ;; create tmp dirs if necessary
  (make-directory live-etc-dir t)
  (make-directory live-tmp-dir t)
  (make-directory live-autosaves-dir t)
  (make-directory live-backups-dir t)
  (make-directory live-custom-dir t)
  (make-directory live-pscratch-dir t)

  ;; Load manifest
  (load-file (concat live-root-dir "manifest.el"))

  ;; load live-lib
  (load-file (concat live-lib-dir "live-core.el"))

  ;;default packs
  (let* ((pack-names '("foundation-pack"
					   "colour-pack"
					   "lang-pack"
					   "power-pack"
					   "git-pack"
					   "org-pack"
					   "clojure-pack"
					   "bindings-pack"))
		 (live-dir (file-name-as-directory "stable"))
		 (dev-dir  (file-name-as-directory "dev")))
	(setq live-packs (mapcar (lambda (p) (concat live-dir p)) pack-names) )
	(setq live-dev-pack-list (mapcar (lambda (p) (concat dev-dir p)) pack-names) ))

  ;; Helper fn for loading live packs

  (defun live-version ()
	(interactive)
	(if (called-interactively-p 'interactive)
		(message "%s" (concat "This is Emacs Live " live-version))
	  live-version))

  ;; Load `~/.emacs-live.el`. This allows you to override variables such
  ;; as live-packs (allowing you to specify pack loading order)
  ;; Does not load if running in safe mode
  (let* ((pack-file (concat (file-name-as-directory "~") ".emacs-live.el")))
	(if (and (file-exists-p pack-file) (not live-safe-modep))
		(load-file pack-file)))

  ;; Load all packs - Power Extreme!
  (mapc (lambda (pack-dir)
		  (live-load-pack pack-dir))
		(live-pack-dirs))

  (setq live-welcome-messages
		(if (live-user-first-name-p)
			(list (concat "Hello " (live-user-first-name) ", somewhere in the world the sun is shining for you right now.")
				  (concat "Hello " (live-user-first-name) ", it's lovely to see you again. I do hope that you're well.")
				  (concat (live-user-first-name) ", turn your head towards the sun and the shadows will fall behind you.")
				  )
		  (list	 "Hello, somewhere in the world the sun is shining for you right now."
				 "Hello, it's lovely to see you again. I do hope that you're well."
				 "Turn your head towards the sun and the shadows will fall behind you.")))


  (defun live-welcome-message ()
	(nth (random (length live-welcome-messages)) live-welcome-messages))

  (when live-supported-emacsp
	(setq initial-scratch-message (concat live-ascii-art-logo " Version " live-version
										  (if live-safe-modep
											  "
;;													   --*SAFE MODE*--"
											"
;;"
											) "
;;			 http://github.com/overtone/emacs-live
;;
;; "													  (live-welcome-message) "

")))
  )

(if (not live-disable-zone)
	(add-hook 'term-setup-hook 'zone))

(if (not custom-file)
	(setq custom-file (concat live-custom-dir "custom-configuration.el")))
(when (file-exists-p custom-file)
  (load custom-file))

(message "\n\n Pack loading completed. Your Emacs is Live...\n\n")
(put 'downcase-region 'disabled nil)
