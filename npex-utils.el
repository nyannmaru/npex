;;this file for making user-interface of the mode
;;

(require 'npex-utils-editmode);npex--open-abbrev-edit-file 
(defgroup npex nil
  "Expanded abbrev-expansion minor-mode"
  :group 'abbrev
  :group 'convenience)


(defconst npex--abbrev-type-list (list "user" "mode" "buffer" "project"))
(defcustom npex-preferred-abbrev-type "user"
  "Type of abbrev file you can access quickly"
  :type '(choice (const :tag "USER" "user")
                 (const :tag "MAJOR-MODE"  "mode")
                 (const :tag "BUFFER" "buffer")
                 (const :tag "PROJECT" "project")))



(defconst npex--template-format-strlist
  (list
   ";;First edit: %s"                  ;;(current-time-string)
   ";;Example is below if you wanna add abbrevs for all modes use 'All or nil"
   ";;(npex-put-definitions 'c++-mode `(\"ab\" \"abbrev\" (bfunc) (afunc) (rfunc)) '(...))"
   "(npex-put-definitions 'ALL"
   "\s`())"))
(defconst npex--template-format-hash 
  #s(hash-table test equal data(
       "user"    ";;User-specific abbrev definition For: %s"
       "mode"    ";;Major-mode specific abbrev definition For: %s"
       "buffer"  ";;Buffer specific abbrev definition For: %s"
       "project" ";;Project specific abbrev definition For: %s")))
;;(gethash "user" npex--template-format-hash)
(defun npex--make-abbrev-template (&optional type)
  (if (null type)
      (let ((fmt (string-join npex--template-format-strlist "\n")))
	(format fmt (current-time-string)))
  (let* ((typekey (car type)) (typeval (cdr type))
	 (upper (seq-take npex--template-format-strlist 1))
	 (middle (list (gethash typekey npex--template-format-hash "")))
	 (bottom (seq-drop npex--template-format-strlist 1))
	 (fmt
	  (string-join (seq-concatenate 'list upper middle bottom) "\n")))
    (format fmt (current-time-string) typeval))))
;;(npex--make-abbrev-template (cons "mode" (symbol-name major-mode)))
(defun npex--insert-abbrev-template (&optional type)
  (insert (npex--make-abbrev-template type)))
;;;lengthy template ends here 

;;;terse one begins
(defconst npex--easy-add-fmt
  "(npex-put-definitions '%s '(\"%s\" \"%s\"))\n");mode-name abbed abbreved
(defun npex--easy-add-make-template-helper (abbreved)
  (let* ((one (string-replace "\\\"" "\"" abbreved)) ;\" --> "
	 (two (string-replace  "\"" "\\\""  one)));  "  --> \"
    two))
(defun npex--easy-add-make-template (abb abbreved &optional mode-name)
  (let ((mode (cond ((null mode-name) "ALL")
		    ((symbolp mode-name) (symbol-name mode-name))
		    (t mode-name))))
    (format npex--easy-add-fmt mode abb (npex--easy-add-make-template-helper abbreved))))
;; (npex--easy-add-make-template "ab" "abbreved")
;; (npex--easy-add-make-template "ab" "abbreved" major-mode)
(defun npex--insert-easy-abbrev-template (abb abbreved &optional mode-name)
  (let ((inserted (npex--easy-add-make-template abb abbreved mode-name)))
    (goto-char (point-max))
    (delete-blank-lines)
    (insert inserted)))

(defun npex--utils-check-error nil
  (unless npex-mode (error "npex-mode is not enabled.")))

(defun npex-list-using-dirs nil
  (interactive)
  (npex--utils-check-error)
  (let ((u (concat "User Dir: " (or npex-using-udir "") "\n"))
	(m (concat "Mode Dir: " (or npex-using-mdir "") "\n"))
	(b (concat "Buff Dir: " (or npex-using-bdir "") "\n"))
	(p (concat "Proj Dir: " (or npex-using-pdir ""))))
    (message (concat u m b p))))
(defun npex-list-using-files nil
    (interactive)
  (npex--utils-check-error)
  (let ((u (concat "User File: " (or npex-using-ufile "") "\n"))
	(m (concat "Mode File: " (or npex-using-mfile "") "\n"))
	(b (concat "Buff File: " (or npex-using-bfile "") "\n"))
	(p (concat "Proj File: " (or npex-using-pfile ""))))
    (message (concat u m b p))))

(defun npex-gethash-file (abbrev-type)
  (interactive (prog2
		   (npex--utils-check-error)
		   (list (completing-read "Select type: " npex--abbrev-type-list nil t))))
  (npex--utils-check-error)
  (unless (member abbrev-type (seq-concatenate 'list npex--abbrev-type-list (list "")))
    (error "%s is not a npex-definition type" abbrev-type))
  (let* ((utype (if (string-empty-p abbrev-type) npex-preferred-abbrev-type abbrev-type))
					;use default when empty-string
	 (file  (gethash utype npex--files-hash nil)))
    (when (called-interactively-p 'interactive)
      (if (null file) (message "Currently %s-type file is not assoced"  utype);FIXME(´・ω・｀)
	(message (concat (format "%s-File: %s" (capitalize utype) file)
			 (if (file-exists-p file) ""
			   "\n\tBut does not exist...")))))
    file))
;;(npex-gethash-file "winter") => throws error
;;(npex-gethash-file "") => returnVal based on npex-preferred-abbrev-type
;;(npex-gethash-file "mode") => mode-file
;;(npex-gethash-file "project") => nil 



(defun npex-edit-abbrevs (&optional type other-window quick-kill)
  "";FIXME(´・ω・｀)needs decent doc
  (interactive
   (prog2
       (npex--utils-check-error)
       (list
	(completing-read "Select the type you want edit: " npex--abbrev-type-list nil t))))
  (npex--utils-check-error)
  (unless (member type npex--abbrev-type-list) (error "'%s' is not a acceptible type" type))
  (let ((file (npex-gethash-file type))
	(utype (if (string-empty-p type) npex-preferred-abbrev-type type)))
    (if file;file is nil 
	(progn (npex--open-abbrev-edit-file file nil #'find-file-other-window)
	       (unless (file-exists-p file)
		 (npex--insert-abbrev-template ;fairly ugly(´・ω・｀)
		  (cons utype (cond ((equal type "user") user-full-name)
				    ((equal type "mode")
				     (symbol-name (oref npex--local-targ-buffer-info tmode)))
				    ((equal type "buffer")
				     (oref npex--local-targ-buffer-info tfilename))
				    ((equal type "project")
				     (oref npex--local-targ-buffer-info tprjname)))))
		 (when (yes-or-no-p (format "Abbrev file for the %s doesn't exist
Is it okay to save the currnet buffer?: " (upcase type)))
		   (save-buffer))))
      (message "currently developping..."))));FIXME(´・ω・｀)setiing hash make file etc




(defun npex-easy-add-region (spt ept &optional abbrev-type)
  (interactive (progn (npex--utils-check-error)
		      (list (region-beginning) (region-end)
			    (completing-read "Enter the type: " npex--abbrev-type-list nil t))))
  (npex--utils-check-error)
  (let* ((word-expanded (buffer-substring-no-properties spt ept))
	 (utype         (if abbrev-type abbrev-type ""))
	 (targ-file     (npex-gethash-file utype)))
    (let ((word-abbreved "") (both-okay nil) (first-try t))
      (while (or first-try (not both-okay));exit as soon as being not first-try and both-okay
	(setf first-try nil word-abbreved "")
	(while (or (string-blank-p word-abbreved);FIXME(´・ω・｀)needs refactor
		   );should notify reasons, take account into using seprating chars or same abbrev-word
	  (setf word-abbreved (string-trim (read-string "Enter Abbreved word: "))))
	(setf both-okay (y-or-n-p (format "Add abbrev '%s' to \n%s" word-abbreved word-expanded))))
	;FIXME(´・ω・｀)definitely needs notif pretifier
      (npex--open-abbrev-edit-file targ-file t)
      ;;procs on the opened temporal buffer
      (npex--insert-easy-abbrev-template word-abbreved word-expanded)
      (basic-save-buffer))))


(provide 'npex-utils)
