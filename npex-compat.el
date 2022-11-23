;;;npex-mode overrides space-key's self-insertion(in most cases) so it would perhaps get costy(´・ω・｀)

;;for making compatible with eldoc-mode
(defun npex--make-compatible-with-eldoc nil
  (eldoc-add-command 'npex-expand-maybe-spc))

;;for inability of the coexistance with the original abbrev-mode
(defvar-local npex--disabled-abbrev-mode-p nil)
(defun npex--disable-abbrev-mode nil
  (when abbrev-mode
    (abbrev-mode 0)
    (setf npex--disabled-abbrev-mode-p t)))


;;all functions above shall be pocketed into this one
(defun npex--make-compatible-with-all nil
  (npex--make-compatible-with-eldoc)
  (npex--disable-abbrev-mode))



;;fuction belows when the minor-mode disabled
(defun npex--revert-abbrev-mode nil
  (when (and npex--disabled-abbrev-mode-p abbrev-mode)
    (abbrev-mode 1)
    (setf npex--disabled-abbrev-mode-p nil)))


(defun npex--exit-npex nil
  (npex--revert-abbrev-mode))



(provide 'npex-compat)
