;;; npex.el --- Minor-mode provides the expanded version of abbrev-expnasion  -*- lexical-binding: t -*-

;; Copyright (C) 2022-2023  Free Software Foundation, Inc.

;; Author: Yuto Sato <nyannmaru.project0214@gmail.com>
;; URL: https://github.com/nyannmaru/npex
;; Version: 0.1.00
;; Keywords: abbrev, convenience
;; Package-Requires: ((emacs "28.2"))

;;; Commentary:
;;later i shall rewrite this in due course(´・ω・｀)




;;abbrev-definitions should be given for each buffer, major-mode and user
;;when enabling the minour-mode these are collected and hashed in a buffer-local hash-table
;;and the mode consults with the hash every time space key is pressed


;;if the word previously feeded on the buffer FOUND on the hash, the mode would do
;;;;eval before-function => substitute the word with the expanded-form => eval after-function
;;else
;;;;insert space naturally (use call-interactively 'self-insert-command)
;;after it one-time cancellation interactive command would be assigned to (kbd "C-g")
;;FIXME(´・ω・｀)not yet

;;for enabling the user escaping the previously occurred expansion
;;should i make an overlay utility?(´・ω・｀)

;;testing purpose
;;(push "~/Desktop/prog/elisp/npex/" load-path)
;;(require 'npfile-kit)

(require 'npex-files)
(require 'npex-compos)
(require 'npex-utils)
(require 'npex-compat)

(defgroup npex nil
  "Expanded abbrev-expansion minor-mode"
  :group 'abbrev
  :group 'convenience)

(defun npex--init-check-errors nil)



(defun npex--init-history nil
  (setf npex--last-definition nil
	npex--last-expanded-word-length nil
	npex--last-triger-char nil
	npex--last-expand-end-marker (make-marker)))

(defun npex--init-all nil
  (npex--init-dirs) (npex--init-files)
  (npex--init-npex-abbrev-hash)
  (npex--init-history))


(defvar npex-global-keymap (let ((map (make-sparse-keymap)))
			     (define-key map (kbd "<SPC>") 'npex-expand-maybe-spc)
			     map))
;;;###autoload
(define-minor-mode npex-mode
  "the minor-mode provide expanded abbrev-expansion."
  :lighter " nEx"
  :keymap npex-global-keymap
  (if npex-mode
      (progn
	(npex--init-all)
	(npex--make-compatible-with-all))
    (npex--exit-npex)))


(provide 'npex)
