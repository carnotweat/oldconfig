(interactive)
(let ((working-buffer (get-buffer-create "*org-find-timestamps working buffer*"))
(occur-buffer-name "*Occur*")
(occur-header-regex "^[0-9]+ match\\(es\\)?") ;; regexp to match for header-lines in *Occur* buffer
first-date
last-date
pretty-dates
swap-dates
(days 0)
date-regex
position-before-year
collect-method
buff
org-buffers)
(save-window-excursion
;; temporary buffer for date-manipulations
(set-buffer working-buffer)
(erase-buffer)
;; ask user for date-range
(setq first-date (org-read-date nil nil nil "Starting date: " nil nil))
(setq last-date (org-read-date nil nil nil "End date: " nil nil))
;; swap dates, if required
(when (string< last-date first-date)
(setq swap-dates last-date)
(setq last-date first-date)
(setq first-date swap-dates))
(setq pretty-dates (concat "from " first-date " to " last-date))
;; construct list of dates in working buffer
;; loop as long we did not reach end-date
(while (not (looking-at-p last-date))
(end-of-buffer)
;; only look for inactive timestamps
(insert "[")
(setq position-before-year (point))
;; Monday is probably wrong, will be corrected below
(insert first-date " Mo]\n")
(goto-char position-before-year)
;; advance number of days and correct day of week
(org-timestamp-change days 'day)
(setq days (1+ days))
)
(end-of-buffer)
;; transform constructed list of dates into a single, optimized regex
(setq date-regex (regexp-opt (split-string (buffer-string) "\n" t)))
;; done with temporary buffer
(kill-buffer working-buffer)
)
;; ask user, which buffers to search and how to present results
(setq collect-method
(car (split-string (org-icompleting-read "Please choose, which buffers to search and how to present the matches: " '("multi-occur -- all org-buffers, list" "org-occur -- this-buffer, sparse tree") nil t nil nil "occur -- this buffer, list")))
)
;; Perform the actual search
(save-window-excursion
(cond ((string= collect-method "occur")
(occur date-regex)
)
((string= collect-method "org-occur")
(if (string= major-mode "org-mode")
(org-occur date-regex)
(error "Buffer not in org-mode"))
)
((string= collect-method "multi-occur")
;; construct list of all org-buffers
(dolist (buff (buffer-list))
(set-buffer buff)
(if (string= major-mode "org-mode")
(setq org-buffers (cons buff org-buffers))))
(multi-occur org-buffers date-regex)))
)
;; Postprocessing: Optionally sort buffer with results
;; org-occur operates on the current buffer, so we cannot modify its results afterwards
(if (string= collect-method "org-occur")
(message (concat "Sparse tree with matches " pretty-dates))
;; switch to occur-buffer and modify it
(if (not (get-buffer occur-buffer-name))
(message (concat "Did not find any matches " pretty-dates))
(set-buffer occur-buffer-name)
(toggle-read-only)
(goto-char (point-min))
;; beautify the occur-buffer by replacing the potentially long original regexp
(while (search-forward (concat " for \"" date-regex "\"") nil t)
(replace-match "" nil t))
(goto-char (point-min))
;; Sort results by matching date ?
(when (y-or-n-p "Sort results by date ? ")
(when (string= collect-method "multi-occur")
;; bring all header lines ('xx matches for ..') to top of buffer, all lines with matches to bottom
(sort-subr t
'forward-line
'end-of-line
;; search-key for this sort only differentiates between header-lines and matche-lines
(lambda () (if (looking-at-p occur-header-regex) 2 1))
nil)
)
;; goto first line of matches
(goto-char (point-max))
(search-backward-regexp occur-header-regex)
(forward-line)
;; sort all matches according to date, that matched the regex
(sort-subr t
'forward-line
'end-of-line
;; search-key for this sort is date
(lambda () (search-forward-regexp date-regex) (match-string 0))
nil
'string<)
;; pretend, that we did not modify the occur-buffer
)
(set-buffer-modified-p nil)
(toggle-read-only)
(message (concat "occur-buffer with matches " pretty-dates " (`C-h m' for help)"))
)
;; switch to occur-buffer
(if (get-buffer occur-buffer-name)
(switch-to-buffer occur-buffer-name))
)
)
)
