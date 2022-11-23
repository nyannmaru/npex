(require 'go-mode)
(defvar-local already-imported nil)
(defun wrapper-go-import-add (package-name)
  (when (null already-imported) (setf already-imported (make-hash-table :test 'equal)))
  (unless (gethash package-name already-imported nil);not already-imported then...
    (puthash package-name t already-imported)
    (go-import-add nil package-name)))
