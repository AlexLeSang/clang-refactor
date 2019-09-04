;;; clang-refactor.el --- Calls clang-refactor on selected region.  -*- lexical-binding: t; -*-

;; Copyright (c) 2019 Valeriy Savchenko (GNU/GPL Licence)

;; Authors: Oleksandr Halushko <alexlesang@gmail.com>
;; URL: https://github.com/AlexLeSang/clang-refactor
;; Version: 0.0.1
;; Keywords: tools, c, c++, clang-refactor

;; This file is NOT part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Small wrapper around clang-refactor cli tool from clang extra tools

;; Keywords: tools, c, c++

;;; Commentary:

;; To install clang-refactor.el make sure the directory of this file is in your
;; `load-path' and add
;;
;;   (require 'clang-refactor)
;;
;; to your .emacs configuration.

;;; Code:
(require 'cl-lib)

(defgroup clang-refactor nil
  "Integration with clang-refactor"
  :group 'tools)

(defcustom clang-refactor-binary (or (executable-find "clang-refactor") "clang-refactor") "Path to clang-refactor executable."
   :type '(file :must-match t)
   :group 'clang-refactor
   :risky t)

(defun pos-to-line-column (pos)
  "Returns line and column of current pos" ;
  (save-excursion (goto-char pos) (concat (number-to-string (line-number-at-pos))
                                          ":"
                                          (number-to-string (current-column))))
  )

;;;###autoload
(defun clang-refactor-extract-region (start end)
  "use clang-refactor to extract the code between START and END.
If called interactively uses the region of the current statement if there is no active region."
  (save-some-buffers :all)
  ;; clang-refactor should not be combined with other operations when undoing.
  (undo-boundary)
  
  (interactive
   (if (use-region-p)
       (progn
        (message (concat "use-region-p " (number-to-string (region-beginning)) " to " (number-to-string (region-end))))
        (list (region-beginning) (region-end)))
     (progn
       (let ((str-starting-point (number-to-string (point))))
         (message (concat "not use-region-p " str-starting-point " to " str-starting-point))
         (list (point) (point)))
       )))

  (let* ((new-name (read-string "Name: " "my_little_function"))
         (file-path (when-let (file-path (buffer-file-name)) (file-truename file-path)))
         (str-region-begin (pos-to-line-column (+ 1 start)))
         (str-region-end (pos-to-line-column (+ 1 end)))
         (clang-extract-arguments " extract -selection=")
         (selection (concat file-path ":" str-region-begin "-" str-region-end)))

    (let ((output-buffer (get-buffer-create "*clang-refactor-errors*")))
      (with-current-buffer output-buffer (erase-buffer))
      (let ((exit-code (call-process
                        clang-refactor-binary nil output-buffer nil
                        "extract"
                        "-i"
                        (format "-selection=%s" selection)
                        "-name"
                        new-name
                        file-path
                        )))
        (if (and (integerp exit-code) (zerop exit-code))
            ;; Success; revert current buffer so it gets the modifications.
            (progn
              (kill-buffer output-buffer)
              (revert-buffer :ignore-auto :noconfirm :preserve-modes))
          ;; Failure; append exit code to output buffer and display it.
          (let ((message (clang-refactor--format-message
                          "clang-refactor failed with %s %s"
                          (if (integerp exit-code) "exit status" "signal")
                          exit-code)))
            (message "%s" message)
            (with-current-buffer output-buffer
              (insert ?\n message ?\n))
            (display-buffer output-buffer)))
        ))
    )
  )

;; ‘format-message’ is new in Emacs 25.1.  Provide a fallback for older
;; versions.
(defalias 'clang-refactor--format-message
  (if (fboundp 'format-message) 'format-message 'format))

(provide 'clang-refactor)
;;; clang-refactor.el ends here
