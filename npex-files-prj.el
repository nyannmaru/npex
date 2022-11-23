(defgroup npex nil
  "Expanded abbrev-expansion minor-mode"
  :group 'abbrev
  :group 'convenience)

(defun npex--get-pname-abpath (dir pname)
  (file-name-concat dir (format npex--pfilename-fmt pname)))
(defconst npex--pfilename-fmt "npex-Pabbrev-%s.el")
(defcustom npex-ptables-dir nil
  "The value must be a normal directory name or nil.
IF non-nil value assigned
       All Project-Level abbrev-tables are recorded inside here.
ELSE
       All Project-Level abbrev-tables are recorded in the top dir of the currently editing project."
  :type 'directory)

(defvar-local npex-using-pdir nil
  "Currently associated directory with the buffer, in which `npex-using-pfile' is placed
the value would be nil or the nearest directory name in where .git folder is placed.");FIXME(´・ω・｀)
(defvar-local npex-using-pfile nil
  "Currently associated file with the buffer in which `npex-mode' is on.
This content defines peject specific abbrev tables in `npex-mode'.

Loaded when enabling the mode and `npex-abbrev-reconfigure' is called.")
(defun npex--get-project-name nil;FIXME(´・ω・｀)
  ""
  "project_name")

(defun npex--get-project-topdir (vcs-controller)
  "Returns the nearest parental fullname-directory that has vcs-controller(such as .git etc),
if it is not found in the upper tree returns nil.") ;FIXME(´・ω・｀)
(defun npex--set-pdir nil)
(defun npex--set-pfile nil)


(provide 'npex-files-prj)
