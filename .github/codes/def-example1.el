'("sim" "Most simple pattern of Npex-Expansion!!")
`("abb" "abbrev" (insert "[Before ") (insert " After]"))


	;;some of mines for 'eamcs-lisp-mode
`(";fix" "" nil (save-excursion (move-end-of-line 1) (insert ";FIXME")))
	;;you have to write nil to before-fun if you wanna add after-fun
`("lam" "lamdba ()" (unless (and (eq (char-before) ?\()
	                             (eq (char-after) ?\)))
		              (insert "()") (backward-char))
	                (backward-char))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Technically spaking, there's no need 1st, 2nd are to be a raw-string

`("ltime" ,(concat "Loading-time:   " (current-time-string)))
;;slight difference preppending comma or not is vital
;;that's why I emphasized a dynamicity on the first sec
`("etime" (concat  "Expanding-time: " (current-time-string)))
