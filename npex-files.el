;;;this file is for
;;;1st) Setting dirs and files when the mode initializing
;;;2nd) Assigning the due value to npex-abbrev-hash when the mode initializing
(require 'npex-files-prj);for assigning and managing Project-Level-abbrev-files

(defgroup npex nil
  "Expanded abbrev-expansion minor-mode"
  :group 'abbrev
  :group 'convenience)

(defconst npex--files-abpath (purecopy load-file-name)
  "this value would be assgned ONLY WHEN NPEX IS LOADED!!!
otherwise nil.
this must be a starting-seed when paths of other npex-files would be assigned")
(defconst npex--mship-dir (if (null npex--files-abpath) ""
			    (file-name-directory npex--files-abpath));FIXME(´・ω・｀)
  "if `npex-utables-dir' or `npex-mtables-dir' is nil, this dir would hold udef and mdef inside it")
;; mothership directory of npex.(note that ends with '/' btw functioning well on windows?(´・ω・｀))

;; For sidestepping the interpreter's complaints about 'inappro type of var
;;(file-name-directory throws) i assigned EmptyString this MUST be checked not to be so
;;when initializing the mode.

;;(file-name-directory "dir1/dir2/file_name.el")

;;---these ones are used when mothership is used as a saving dir---;
(defconst npex--utsdir-name "user-tables")
(defconst npex--mtsdir-name "mode-tables")
(defconst npex--unnamed-buffer-dir-name "unnamed-buffer-tables")
;;---these ones are used only when mothership is used as a saving dir---;



;;it may be better to be defcustom
(defconst npex--ufilename-fmt "npex-Uabbrev-%s.el")
(defconst npex--mfilename-fmt "npex-Mabbrev-%s.el")
(defconst npex--bfilename-fmt "npex-Babbrev-%s.el")




(defconst npex--utables-defdir (file-name-concat npex--mship-dir npex--utsdir-name)
  "Default directory in which all user-specific abbrev-tables are put.
When the value of `npex-utables-dir' is non-nil it will supersede the roll of this one")
(defconst npex--mtables-defdir (file-name-concat npex--mship-dir npex--mtsdir-name)
  "Default directory in which all user-specific abbrev-tables are put.
When the value of `npex-utables-dir' is non-nil it will supersede the roll of this one")
(defconst npex--unnamed-btables-defdir (file-name-concat npex--mship-dir
							npex--unnamed-buffer-dir-name)
  "Default directory in which all user-specific abbrev-tables are put.
When the value of 'npex-btables-dir' is non-nil this dir moves into it")

(defcustom npex-utables-dir nil
  "The value must be a normal directory name or nil.
IF non-nil value assigned
       All User-Level abbrev-tables are recorded here.
ELSE
       All User-Level abbrev-tables are recorded inside `npex--utables-defdir'"
  :type 'directory)
(defcustom npex-mtables-dir nil
  "The value must be a normal directory name or nil.
IF non-nil value assigned
       All Major-Mode-Level abbrev-tables are recorded here.
ELSE
       All Major-Mode-Level abbrev-tables are recorded inside `npex--utables-defdir'"
  :type 'directory)
(defcustom npex-btables-dir nil
  "The value must be a normal directory name or nil.
IF non-nil value assigned
       All Buffer-Level abbrev-tables are recorded here.
ELSE
       All Buffer-Level abbrev-tables are recorded in the same dir with the current buffer(=present working directory) or inside `npex--unnamed-btables-defdir'(when it is unable to get buffer-name and pwd)"
  :type 'directory)






;;;belows are initialized when the mode is enabled 
;;that is, perhaps should delay assignments

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;------------------------------user-------------------;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar-local npex-using-udir nil
  "Currently associated directory with the buffer, in which `npex-using-ufile' is placed.
the value would be either one of `npex-utables-dir' or `npex--utables-defdir'.

The value would be assigned when `npex-mode' is enabled.")
(defvar-local npex-using-ufile nil
  "Currently associated file with the buffer in which `npex-mode' is on.
This content defines User = `user-full-name' specific abbrev tables in `npex-mode'.

The value would be assigned when `npex-mode' is enabled.")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;------------------------------mode-------------------;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar-local npex-using-mdir nil
  "Currently associated directory with the buffer, in which `npex-using-mfile' is placed
the value would be either one of `npex-mtables-dir' or `npex--mtables-defdir'.

The value would be assigned when `npex-mode' is enabled.")
(defvar-local npex-using-mfile nil
  "Currently associated file with the buffer in which `npex-mode' is on.
This content defines Major-Mode = `major-mode' specific abbrev tables in `npex-mode'.

The value would be assigned when `npex-mode' is enabled.")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;---------------------------buffer--------------------;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar-local npex-using-bdir nil
  "Currently associated directory with the buffer, in which `npex-using-bfile' is placed
the value would be either one of `npex-btables-dir', present-working-directory or `npex--unnamed-btables-defdir'.

The value would be assigned when `npex-mode' is enabled.")
(defvar-local npex-using-bfile nil
  "Currently associated file with the buffer in which `npex-mode' is on.
This content defines Buffer = `buffer-file-name' specific abbrev tables in `npex-mode'.

The value would be assigned when `npex-mode' is enabled.")




(defvar-local npex--dirs-hash nil)
(defun npex--set-udir nil
  (setf npex-using-udir (file-name-as-directory (or npex-utables-dir npex--utables-defdir))))
(defun npex--set-mdir nil
  (setf npex-using-mdir (file-name-as-directory (or npex-mtables-dir npex--mtables-defdir))))
(defun npex--set-bdir nil
  (let ((bname (buffer-file-name)))
    (if bname;it is able to get buffer-name
	(setf npex-using-bdir;;btables-dir or present-working-directory
	      (file-name-as-directory (or npex-btables-dir default-directory)))
      (setf npex-using-bdir;unable to get 
	    (file-name-as-directory
	     (cond (npex-btables-dir npex-btables-dir)
		   (default-directory default-directory)
		   (t npex--unnamed-btables-defdir)))))))



(defun npex--set-dirs nil
  (npex--set-udir) (npex--set-mdir) (npex--set-bdir)
  (npex--set-pdir));FIXME(´・ω・｀)has no implementation...


;;;presumes that npex-dirs are set
(defun npex--name-ufile-abpath nil
  (file-name-concat npex-using-udir
		    (format npex--ufilename-fmt user-full-name)))
(defun npex--name-mfile-abpath nil
  (file-name-concat npex-using-mdir
		    (format npex--mfilename-fmt (symbol-name major-mode))))
(defun npex--name-bfile-abpath nil
  (let ((bname (buffer-file-name)))
    (if bname
	(let* ((ex-seed (file-name-extension bname))
	       (ex (if ex-seed (capitalize ex-seed) "NoExt"))
	       (bbase (file-name-base bname))
	       (tail (format npex--bfilename-fmt (concat bbase ex))))
	  (file-name-concat npex-using-bdir tail))
      (file-name-concat npex-using-bdir "npex--UNNAMED-BUFFER.el"))))

(defun npex--set-ufile nil
  (setf npex-using-ufile (npex--name-ufile-abpath)))
(defun npex--set-mfile nil
  (setf npex-using-mfile (npex--name-mfile-abpath)))
(defun npex--set-bfile nil
  (setf npex-using-bfile (npex--name-bfile-abpath)))
(defun npex--set-files nil
  (npex--set-ufile) (npex--set-mfile) (npex--set-bfile)
  (npex--set-pfile));FIXME






(defvar-local npex--dirs-hash nil)
(defvar-local npex--files-hash nil)
(defun npex--make-dirs-hash nil
  (setf npex--dirs-hash (make-hash-table :test 'equal :size 4))
  (puthash "user" npex-using-udir npex--dirs-hash)
  (puthash "mode" npex-using-mdir npex--dirs-hash)
  (puthash "buffer" npex-using-bdir npex--dirs-hash)
  (puthash "project" npex-using-pdir npex--dirs-hash))
(defun npex--make-files-hash nil
  (setf npex--files-hash (make-hash-table :test 'equal :size 4))
  (puthash "user" npex-using-ufile npex--files-hash)
  (puthash "mode" npex-using-mfile npex--files-hash)
  (puthash "buffer" npex-using-bfile npex--files-hash)
  (puthash "project" npex-using-pfile npex--files-hash))
(defun npex--init-dirs nil
  (npex--set-dirs) (npex--make-dirs-hash))
(defun npex--init-files nil
  (npex--set-files) (npex--make-files-hash))
;;;dirs and files setting ends here


;;;begins npex-abbrev-hash settings

(defvar-local npex--init-load-erred-list nil
  "List of all error when the mode is enabled
whose elems are typeof (cons type file).")
(defvar-local npex--init-loaded-list nil
  "List of all loaded successfully when the mode is enabled
whose elems are typeof (cons type file).")
(defvar-local npex--init-blocked-list nil
  "List of all blocked when the mode is enabled.
 whose elems are typeof (cons type file).")
(defcustom npex-block-type-list nil
  "List of types on which are blocked from loading when `npex-mode' is enabled."
  :type 'list)
(defcustom npex-notify nil
  "When it is non nil `npex-mode' notifies all file status other than error."
  :type 'boolean)
(defconst npex--precedence
  (list "user" "mode" "project" "buffer"))
(defun npex--set-npex-abbrev-hash nil
  (setf npex-abbrev-hash (make-hash-table :test 'equal :size 150)))
(defun npex--init-make-lists-nil nil
  (setf npex--init-load-erred-list nil
	npex--init-loaded-list     nil
	npex--init-blocked-list    nil))
(defun npex--init-load-abbrev-def-files nil
  (dolist (type npex--precedence)
    (let ((file (npex-gethash-file type)))
      (cond ((member type npex-block-type-list);when type blocked
	     (push (cons type file) npex--init-blocked-list))
	    ((and file (file-exists-p file) (file-regular-p file));when file exists
	     (condition-case err
		 (progn (load file nil t)
			(push (cons type file) npex--init-loaded-list))
	       (error;when load error
		(push (format "Loading Error occurred at file: '%s'\n\t%s"
			      file (propertize (error-message-string err) 'face 'error))
		      npex--init-load-erred-list))))
	    (t nil);FIXME(´・ω・｀) file maybe nil
	    ))))
(defun npex--init-notify-load-error nil
  (when npex--init-load-erred-list
    (message "%s" (string-join npex--init-load-erred-list "\n"))))
(defun npex--init-notify-all nil)
(defun npex--assign-npex-abbrev-hash nil
  (npex--init-make-lists-nil)
  (npex--init-load-abbrev-def-files)
  (npex--init-notify-load-error)
  (when npex-notify (npex--init-notify-all)))

    
(defun npex--init-npex-abbrev-hash nil
  (npex--set-npex-abbrev-hash)
  (npex--assign-npex-abbrev-hash))


(provide 'npex-files)

