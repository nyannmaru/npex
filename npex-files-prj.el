(require 'files)
(defgroup npex nil
  "Expanded abbrev-expansion minor-mode"
  :group 'abbrev
  :group 'convenience)
(defconst npex--pfilename-fmt "npex-Pabbrev-%s.el")
(defcustom npex-project-topdirs nil
  "list of strings of directory-names inside them Project-specific-npex-abbrevs are defined. (prjtop1 prjtop2 ... prjtopN)"
  :type 'list);FIXME(´・ω・｀)should add some utility

(defvar-local npex-using-pdir nil
  "Currently associated directory with the buffer, in which `npex-using-pfile' is placed
the value would be nil or the nearest directory name in where .git folder is placed.")
(defvar-local npex-using-pfile nil
  "Currently associated file with the buffer in which `npex-mode' is on.
This content defines peject specific abbrev tables in `npex-mode'.

Loaded when enabling the mode and `npex-abbrev-reconfigure' is called.")
(defun npex--set-pdir nil
  (let* ((absfname (buffer-file-name))
	 (abspdirs (seq-map #'file-truename npex-project-topdirs))
	 (filtered (seq-filter (lambda (dir) (string-prefix-p dir absfname))
			       abspdirs))
	 (sorted (seq-sort (lambda (s1 s2) (> (length s1) (length s2))) filtered)))
    (if filtered;if registered as a topdir
	(setf npex-using-pdir (file-name-as-directory (car sorted)))
      (setf npex-using-pdir nil))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;belows are based on using-pdir
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun npex--get-project-name (&optional pdir)
  (when pdir
    (let ((trimmed (string-trim-right pdir "[\\/]")))
      (file-name-base trimmed))));FIXME(´・ω・｀)should check in windows
(npex--get-project-name "some/thing/like/this")

(defun npex--name-pfile-abpath nil
  (when npex-using-pdir
    (let ((pname (npex--get-project-name npex-using-pdir)))
      (file-name-concat npex-using-pdir (format npex--pfilename-fmt pname)))))

(defun npex--set-pfile nil
  (if npex-using-pdir
      (setf npex-using-pfile (npex--name-pfile-abpath))
    (setf npex-using-pfile nil)))
(defun npex--assign-pabbrev nil
  "Registers pdir and pfile into the current buffer's hash
and Save customization in the init.el"
  (let ((dir (read-directory-name "Enter the current buffer's project top directory: \n")))
    (setf npex-using-pdir (directory-file-name dir)
	  npex-using-pfile (npex--name-pfile-abpath))
    (puthash "project" npex-using-pdir npex--dirs-hash)
    (puthash "project" npex-using-pfile npex--files-hash)
  ;;and then register hash
    (customize-save-variable 'npex-project-topdirs (cl-pushnew dir npex-project-topdirs
							       :test #'string-equal))))

;;add this to the edit-abbrev- ;FIXME(´・ω・｀)

(provide 'npex-files-prj)
