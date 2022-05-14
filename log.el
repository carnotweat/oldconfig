(setq org-capture-templates
  `(("t" "TODO" entry (file+datetree "~/org/tasks.org"  "Tasks")
     "* TODO [#C] %?\n   SCHEDULED: <%<%Y-%m-%d %a>>\n  [%<%Y-%m-%d %a>]\n  %a")
   ("T" "Travel" entry (file+datetree+prompt "~/org/travel.org")
    "* %?\n  :PROPERTIES:\n  :LOCATION:\n  :END:\n  %t\n  %a")
   ("j" "Journal Note" entry (
               file+olp+datetree
               ,(concat
                 org-directory
                 (format-time-string "journal-%m-%d.org")))
   "* Event: %?\n %i\n  From: %a")
   )
  )
