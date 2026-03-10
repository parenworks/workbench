(in-package #:workbench)

(defun timestamp-now ()
  (now))

(defun format-timestamp (timestamp)
  "Format a local-time timestamp as an ISO 8601 string for DB storage."
  (local-time:format-timestring nil timestamp))

(defun parse-timestamp (string)
  "Parse an ISO 8601 string back into a local-time timestamp."
  (when string
    (local-time:parse-timestring string)))
