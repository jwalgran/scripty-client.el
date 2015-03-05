;;; scripty-client.el --- Run scripty from emacs

(require 'dash)
(require 's)

(defvar scripty-executable "scripty")

(defvar scripty-last-script nil "do not hand-edit")
(put 'scripty-last-script 'risky-local-variable t)

(defvar scripty-last-args nil "do not hand-edit")
(put 'scripty-last-args 'risky-local-variable t)

(defun scripty-get-choices ()
  (interactive)
  (let* ((list-command (concat scripty-executable " -l"))
         (cmd-results (shell-command-to-string list-command))
         (lines (if (equal "" cmd-results) '() (s-split "\n" cmd-results))))
    (-map 's-trim lines)))

(defun get-args (prefix)
  (cond
    ((equal prefix '(4)) "")
    ((equal prefix '(16)) scripty-last-args)
    (t (read-string "args: " scripty-last-args))))

(defun get-script (prefix)
  (if (equal prefix '(16))
    (list  scripty-last-script)
    (list (ido-completing-read "command: " (scripty-get-choices) nil t scripty-last-script))))

(defun scripty (arg)
  (interactive 
   (let ((choices (scripty-get-choices)))
     (if (null choices)
         '("")
       (get-script current-prefix-arg))))
  (if (equal arg "")
      (message "No scripty dir found")
    (let ((additional-args (get-args current-prefix-arg)))
      (setq scripty-last-script arg)
      (setq scripty-last-args additional-args)
      (async-shell-command (concat scripty-executable " " arg " " additional-args)
                           (concat "*scripty-" arg "*")))))

(provide 'scripty-client)
