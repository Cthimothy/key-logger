(defun tw/keylog-toggle ()
  "Toggle key logging with timestamps. Only logs keys starting with C- or M-, ignoring mouse events."
  (interactive)
  (let* ((hook-symbol 'tw/keylog--log-command-hook))
    (unless (fboundp hook-symbol)
      (fset hook-symbol
            (lambda ()
              (let* ((buffer-name "*Key Log*")
                     (keys (key-description (this-command-keys-vector))))
                (unless (or (string-match-p "<mouse-" keys)
                            (string-match-p "<wheel-" keys)
                            (string-match-p "<double-" keys)
                            (string-match-p "<triple-" keys)
                            (string-match-p "<down-mouse-" keys)
                            (string-match-p "<drag-mouse-" keys))
                  (when (or (string-prefix-p "C-" keys)
                            (string-prefix-p "M-" keys))
                    (let ((timestamp (format-time-string "%Y-%m-%d %H:%M:%S")))
                      (with-current-buffer (get-buffer-create buffer-name)
                        (goto-char (point-max))
                        (unless (bolp)
                          (insert "\n"))
                        (insert (format "[%s] %s" timestamp keys))
                        (dolist (win (get-buffer-window-list (current-buffer) nil t))
                          (with-selected-window win
                            (goto-char (point-max)))))))))))
    (if (member hook-symbol post-command-hook)
        (progn
          (remove-hook 'post-command-hook hook-symbol)
          (message "Key logging stopped."))
      (add-hook 'post-command-hook hook-symbol)
      (message "Key logging started in *Key Log*"))))




