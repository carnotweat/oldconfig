(require 'org-element)

(defun zin/org-file-from-subtree (&optional name)
  "Cut the subtree currently being edited and create a new file
from it.

If called with the universal argument, prompt for new filename,
otherwise use the subtree title."
  (interactive "P")
  (org-back-to-heading)
  (let ((filename (cond
                   (current-prefix-arg
                    (expand-file-name
                     (read-file-name "New file name: ")))
                   (t
                    (concat
                     (expand-file-name
                      (org-element-property :title
                                            (org-element-at-point))
                      default-directory)
                     ".org")))))
    (org-cut-subtree)
    (find-file-noselect filename)
    (with-temp-file filename
      (org-mode)
      (yank))))
