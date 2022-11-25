;;part of npex-utils
(defgroup npex nil
  "Expanded abbrev-expansion minor-mode"
  :group 'abbrev
  :group 'convenience)
;;(set 'some (list :some "test" :something "something's"))
;;(plist-get some :something)
;;should use raw?
(defclass npex--targ-buffer-info nil
  ((tbuffer   :initarg :tbuffer :type (or buffer nil))
   (tfilename :initarg :tfilename :type string)
   (tmode     :initarg :tmode :type (or symbol nil))
   (tprjname  :initarg :tprjname :type (or string nil))
   (tqkillp   :initarg :tqkillp  :type boolean)))
(defun npex--make-targ-buffer-info (quick-kill-p)
  (npex--targ-buffer-info :tbuffer (current-buffer)
			  :tfilename (let ((bf (buffer-file-name)))
				       (if bf bf
					 ""))
			  :tmode major-mode
			  :tprjname (npex--get-project-name)
			  :tqkillp (when quick-kill-p t)))
;;(npex--make-targ-buffer-info "quick-killp!(´・ω・｀)")
(defvar npex--global-targ-buffer-info nil
  "var used when `npex--open-abbrev-edit-file' is called")
(defvar-local npex--local-targ-buffer-info nil
  "var used when `npex--open-abbrev-edit-file' is called")



(defun npex--load-this-on-targ-buffer-when-save nil
  "this one would be added into `after-save-hook' by `npex--edit-abbrev-definition-mode'"
  (let ((this (buffer-file-name));fullname of the edit-mode-buffer loading purpose
	(load-error nil))
    (with-current-buffer (oref npex--local-targ-buffer-info tbuffer)
      (condition-case err (load this nil t)
	(error (setf load-error (propertize (error-message-string err) 'face 'error)))))
    (if load-error
	(message "%s" (format "Error occurred while loading this file...\n==> %s" load-error))
      (message "Npex Abbrev Definition at '%S' updated"
	       (oref npex--local-targ-buffer-info tbuffer)))
    (when (and (null load-error) (oref npex--local-targ-buffer-info tqkillp))
      (kill-buffer (current-buffer)))))
  
(defun npex--edit-abbrev-targ-messenger nil
  "this one would be added to `post-command-hook' by `npex--edit-abbrev-definition-mode'"
  (unless (current-message)
    (message "Npex: 'SAVE' this buffer for updating abbrevs at %S" 
	     (oref npex--local-targ-buffer-info tbuffer))))


(defvar npex--edit-abbrev-mode-keymap (let ((map (make-sparse-keymap)))
					map))
(define-minor-mode npex--edit-abbrev-definition-mode
  "helper minor-mode for only editing npex definition.
enabled automatically when calling `npex--open-abbrev-edit-file'"
  :lighter " nExEd"
  :keymap   npex--edit-abbrev-mode-keymap
  (if npex--edit-abbrev-definition-mode
      (progn
	(npex-mode -1);;EASILY GETS MESSY WHEN ENALBLED(´・ω・｀)
	(add-hook 'after-save-hook #'npex--load-this-on-targ-buffer-when-save nil t)
	(add-hook 'post-command-hook #'npex--edit-abbrev-targ-messenger       nil t))
    (remove-hook 'after-save-hook #'npex--load-this-on-targ-buffer-when-save t)
    (remove-hook 'post-command-hook #'npex--edit-abbrev-targ-messenger       t)))



(defun npex--open-abbrev-edit-file (file &optional quick-kill find-file-kind-func)
  "
1, set global one
2, open edit-file
3, enable edit-mode in the edit-file
4, move the val of global to local
"
  (setf npex--global-targ-buffer-info (npex--make-targ-buffer-info quick-kill));task1, done
  (if find-file-kind-func
      (funcall find-file-kind-func file)
    (find-file file));task2 done
    ;;;;;newly opened file operations
  (npex--edit-abbrev-definition-mode 1);task3 done
  (setf npex--local-targ-buffer-info npex--global-targ-buffer-info
	npex--global-targ-buffer-info nil));task4 done



(provide 'npex-utils-editmode)
