(in-package #:workbench)

(defun row-to-session (row)
  "Convert a database row plist to a session instance."
  (when row
    (make-instance 'session
                   :id (getf row :|id|)
                   :user-id (getf row :|user_id|)
                   :session-token (getf row :|session_token|)
                   :expires-at (parse-timestamp (getf row :|expires_at|))
                   :created-at (parse-timestamp (getf row :|created_at|)))))

(defun find-session-by-token (token)
  "Find a session by its token string. Returns a session instance or NIL."
  (let ((result (execute-sql "SELECT * FROM sessions WHERE session_token = ?" (list token))))
    (row-to-session (fetch-one result))))

(defun save-session (session)
  "Insert a session record in the database."
  (validate session)
  (execute-sql
   "INSERT INTO sessions (id, user_id, session_token, expires_at, created_at)
    VALUES (?, ?, ?, ?, ?)"
   (list (entity-id session)
         (session-user-id session)
         (session-token session)
         (format-timestamp (session-expires-at session))
         (format-timestamp (created-at session))))
  session)

(defun delete-session-by-token (token)
  "Delete a session by its token."
  (execute-sql "DELETE FROM sessions WHERE session_token = ?" (list token))
  t)

(defun delete-expired-sessions ()
  "Remove all sessions whose expires_at is in the past."
  (execute-sql "DELETE FROM sessions WHERE expires_at < ?"
               (list (format-timestamp (timestamp-now))))
  t)

(defun delete-sessions-for-user (user-id)
  "Delete all sessions belonging to a user."
  (execute-sql "DELETE FROM sessions WHERE user_id = ?" (list user-id))
  t)
