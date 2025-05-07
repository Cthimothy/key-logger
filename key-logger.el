(defvar my-keylog-buffer "*Key Log*"
  "Buffer name for displaying logged keystrokes.")

(defvar my-keylog-active nil
  "Flag to track whether key logging is active.")

(defun my-log-command-with-timestamp ()
  "Append the current keystroke with timestamp to `my-keylog-buffer`, ignoring mouse events."
  (let* ((keys (key-description (this-command-keys-vector))))
    (unless (or (string-match-p "<mouse-" keys)
                (string-match-p "<wheel-" keys)
                (string-match-p "<double-" keys)
                (string-match-p "<triple-" keys)
                (string-match-p "<down-mouse-" keys)
                (string-match-p "<drag-mouse-" keys))
      (let ((timestamp (format-time-string "%Y-%m-%d %H:%M:%S")))
        (with-current-buffer (get-buffer-create my-keylog-buffer)
          (goto-char (point-max))
          (unless (bolp)
            (insert "\n"))
          (insert (format "[%s] %s" timestamp keys))
          (dolist (win (get-buffer-window-list (current-buffer) nil t))
            (with-selected-window win
              (goto-char (point-max)))))))))

(defun my-toggle-keylog ()
  "Toggle key logging with timestamps, ignoring all mouse events."
  (interactive)
  (if my-keylog-active
      (progn
        (remove-hook 'post-command-hook #'my-log-command-with-timestamp)
        (setq my-keylog-active nil)
        (message "Key logging stopped."))
    (add-hook 'post-command-hook #'my-log-command-with-timestamp)
    (setq my-keylog-active t)
    (message "Key logging started. See buffer %s" my-keylog-buffer)))
