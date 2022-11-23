(defgroup npex nil
  "Expanded abbrev-expansion minor-mode"
  :group 'abbrev
  :group 'convenience)

(defvar-local npex-abbrev-hash nil
  "In most cases, you should not fiddle this variable by hand
This variable(whose type is hash:stiring -> npex-definition-object) assigned automatically when `npex-mode' is enabled.
When a word on the buffer before the cursor is registered as a key string of this hashing value, the mode expands the word.")
;;(setf npex-abbrev-hash (make-hash-table :test 'equal))
(defun npex--put-abbrev-hash (abbrev-def)
  "most-internal function when making up `npex-abbrev-hash'
this function checks the validity about the length of a given definition(must suffice 2<= lenght <=5)
and about the first term(must be a string object and not string-empty)
"
  (let ((header (eval (car abbrev-def)))
	(len    (length abbrev-def)))
    (cond ((not (<= 2 len 5)) (error "abbrev-put-hash error definition's length need to be equal to 2, 3, 4 or 5"))
	  ((not (stringp header)) (error "abbrev-put-hash error the first term is not a string"))
	  ((string-empty-p header) (error "abbrev-put-hash error the first term can not be empty-string")))
    (puthash header (cons header (cdr abbrev-def)) npex-abbrev-hash)))
		       ;hash:"as" → '("as" "abbStr" beforef afterf revertf)


;;;this one is most frequently used interface FIXME(´・ω・｀) needs a decent doc
(defun npex-put-definitions (major-mode-name &rest abbrev-defs)
  "This function is for assigning the value of `npex-abbrev-hash'.
'major-mode-name' is a symbol, nil or \'ALL(note that it is all capitalised letters and quoted).
this argument determines when to put the given abbrev-definitions into the hash according as the relationship whether a given symbol is inherited by the value of `major-mode' or not.
for example, when you wanna add abbrevs for only programming-relating major-modes you should feed 'prog-mode or you wanna add more specifically for only el-editing major-mode you should 'emacs-lisp-mode etc...
when it is nil or 'ALL abbrev-definitions are put for every major-mode.


'abbrev-defs' are each quoted-list such as like \'(\"ab\" \"abbrev\" (before-function) (after-function) (revert-function))
1st term must be a string-object, an expression returns string or a symbol string is assigned before the `npex-mode' is enabled(NOTE!! if this string holds one of `npex-separating-chars' as a string constituent, it would never be usable!).

2nd term is basically the same with the 1st one, but its evaluation is delayed until its definition is used by the mode.

3rd term needs to be an expression(if it is lambda-form, it would be ignored) would be evaluated when after 1st string on the buffer deleted before 2nd string inserted.
It is mainly for the side-effects only all return value of this expression would be ignored.

4th term is the same with the 3rd but would be evaluated when after 2nd term is inserted on the buffer.

5th term is evaluated only when `npex-escape-expansion' is called in order to revert side-effects of 3rd and 4th terms

(ex
\"\"\"
(npex-put-definitions \'ALL
  '(\"edate\" (concat \"expanded when \" (current-time-string)))
  '((symbol-name major-mode) \"\" nil (progn (message \"this is possible as long as\")
                                             (message \"major-mode has some value\")
                                             (message \"when loading npex-put-def\"))))
\"\"\"
plz, exchange ’ with apostroph(´・ω・｀)

\(fn mode-sym &rest '(abb abbreved before-func after-func reverse-func) ...)"
  (declare (indent 1))
  (when (and (not (or (null abbrev-defs) (null (car abbrev-defs))));to avoid putting nil → nil
	     (or (derived-mode-p major-mode-name) (or (eq major-mode-name 'ALL)
						      (eq major-mode-name nil))));decent doc for 'All
    (dolist (abbrev-def abbrev-defs)
      (npex--put-abbrev-hash abbrev-def))))
;; (npex-put-definitions 'prog-mode)
;; (npex-put-definitions 'prog-mode nil)
;; (npex-put-definitions  'ALL
;;  '("some" "something" nil (search-backward "some"))
;;  '("so" "I'm soso" nil (message "Hello! How are you?") (message "by the way, who the hell are you?"))
;;  '("nof" "updated!!"))


(defun npex--get-definition  (abbrev-str)
  (gethash abbrev-str npex-abbrev-hash nil))

(defsubst npex--salvage-abbreved-word (abbrev-def)
  (car abbrev-def))
(defsubst npex--salvage-expanded-word (abbrev-def)
  (cadr abbrev-def))
(defsubst npex--salvage-before-function (abbrev-def)
  (caddr abbrev-def))
(defsubst npex--salvage-after-function (abbrev-def)
  (cadddr abbrev-def))
(defsubst npex--salvage-revert-function (abberv-def)
  (let ((temp (cddddr abberv-def)))
    (car temp)))
;; (eval (npex--salvage-revert-function (npex--get-definition "so")))

(defcustom npex-separating-chars
  (list ?\s ?\t ?\" ?\' ?\[ ?\( ?\{ ?\) ?\] ?\})
  "This var is used when `npex--get-before-word' is called.
Value must be a list of characters, if a character is in, it is treated as a separating point on the buffer when `npex-mode' getting a word, but at the same time you can't use these chars as a abbreved word constituent"
  :type 'list)
(defun npex--get-before-word nil
  "returns word(more properly speaking, the longest(length may be 0) expression that doesn't have space- or tab-char inside it) written on the buffer before the point."
  (let* ((line-string (buffer-substring-no-properties (point-at-bol) (point)))
	 (split-it (split-string line-string
			(regexp-opt-charset npex-separating-chars)))
	 (last-one (seq-first (seq-reverse split-it))))
    last-one))


(defvar-local npex--last-definition nil)
(defvar-local npex--last-expanded-word-length nil)
(defvar-local npex--last-triger-char nil)

(defvar-local npex--last-expand-end-marker nil)

(defcustom npex-expansion-before-hook nil
  "Hook runs everytime before `npex--expand-definition' expands definition."
  :type 'hook)
(defcustom npex-expansion-middle-hook nil
  "Hook runs everytime after 'npex--expand-definition' deletes the current buffer abbreved word and before expanded word inserted"
  :type 'hook)
(defcustom npex-expansion-after-hook nil
  "Hook runs everytime after `npex--expand-definition' evals after-function of the definition"
  :type 'hook)
(defun npex--expand-definition (definition)
  "execute the feeded npex-definition in the current buffer.
a, ==Run `npex-expansion-before-hook' hook==
1, Delete the written abbreved word from the current buffer.
2, Eval the before function(not inside `save-excursion').
b, ==Run `npex-expansion-middle-hook' hook==
3, Insert the expanded form of the abbreved word.
4, Eval the after function.
c, ==Run `npex-expansion-after-hook'  hook=="
  
  (let ((cpt (point))
	(abbreved-word (npex--salvage-abbreved-word definition))
	(expanded-word (eval (npex--salvage-expanded-word definition))))
    (unless (stringp expanded-word) (error "npex 2nd term of '%s' is not a string"
					   abbreved-word))
    (let ((len  (length expanded-word))
	  (bfun (npex--salvage-before-function definition))
	  (afun (npex--salvage-after-function definition)))
      (run-hooks 'npex-expansion-before-hook);a
      (delete-char (- (length abbreved-word)) t);1
      (eval bfun);2
      (run-hooks 'npex-expansion-middle-hook);b
      (insert expanded-word);3
      (setf npex--last-definition definition
	    npex--last-expanded-word-length len)
      (move-marker npex--last-expand-end-marker (point))
      (eval afun);4
      (run-hooks 'npex-expansion-after-hook)
    )))
;; (defun test-expansion nil
;;   (interactive)
;;   (let ((def (npex--get-definition "so")))
;;     (npex--expand-definition def)))



(defcustom npex-should-append-self-insertion nil
  "Determines whether appending input char after the abbrev-expansion."
  :type 'boolean)
(defun npex-escape-expansion nil
  (interactive)
  (unless npex-mode (error "npex-mode is not enabled."))
  
  (let ((pt (marker-position npex--last-expand-end-marker))
	(err-str) (header (car npex--last-definition)))
    (if (not (and npex--last-definition npex--last-expanded-word-length npex--last-triger-char pt))
	(message "No abbrev-expnasion occurred recently.")
      (goto-char pt)

      (undo);FIXME(´・ω・｀)
      ;; (delete-char (- npex--last-expanded-word-length) t)
      ;; (insert (npex--salvage-abbreved-word npex--last-definition))
      (condition-case err
	  (eval (npex--salvage-revert-function npex--last-definition))
	(error (setf err-str (propertize (error-message-string err) 'face 'error))))
      (if (null npex-should-append-self-insertion)
	  (self-insert-command 1 npex--last-triger-char);FIXME(´・ω・｀)may be fairly problematic...
	(forward-char))
      (setf npex--last-definition nil npex--last-expanded-word-length nil)
      (move-marker npex--last-expand-end-marker nil)
      (npex--set-onetime-escaper-helper))
    (if err-str (message "abbrev-word '%s' assoced revertf didn't work well\n %s"
			   header err-str)
      (message "reversion done!"))))
(defun npex--set-onetime-escaper nil
  "alter C-g keybinding in a moment."
  (local-set-key (kbd "C-g") 'npex-escape-expansion)
  (add-hook 'post-command-hook     'npex--set-onetime-escaper-helper nil t)
  (add-hook 'post-command-hook     'npex--set-onetime-escaper-messenger nil t))
(defun npex--set-onetime-escaper-messenger nil
  (interactive)
  (unless (current-message)
    (message "Press [C-g] to escape the expansion happened before")))
(defconst npex-escape-killing-command-heads
  (list "begin" "end" "forward" "backward" "indent" "npex"
	"previous" "next" "move" "newline" "self" "insert"
	"set" "undo"))

(defun npex--set-onetime-escaper-helper (&optional forcing)
  (interactive)
  (let ((command-head (car (split-string (symbol-name this-command) "-"))))
    (when (member command-head npex-escape-killing-command-heads)
      (local-unset-key (kbd "C-g"))
      (remove-hook 'post-command-hook 'npex--set-onetime-escaper-messenger  t)
      (remove-hook 'post-command-hook 'npex--set-onetime-escaper-helper t)
      (message ""))))


(defun npex-expand-maybe-spc nil
  (interactive)
  (let* ((word (npex--get-before-word))
	 (def  (npex--get-definition word)))
    (if def
	(progn (setf npex--last-triger-char ?\s)
	       (npex--expand-definition def)
	       (when npex-should-append-self-insertion
		 (call-interactively #'self-insert-command))
	       (npex--set-onetime-escaper))
      (call-interactively #'self-insert-command))))
;;(local-set-key (kbd "SPC") 'npex-expand-maybe-spc)
;;npex-abbrev-hash


(provide 'npex-compos)
