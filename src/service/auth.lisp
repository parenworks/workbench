(in-package #:workbench)

(defun generate-session-token ()
  "Generate a random session token string."
  (ironclad:byte-array-to-hex-string
   (ironclad:random-data 32)))

(defun session-expiry-time ()
  "Return a timestamp for when a new session should expire."
  (local-time:adjust-timestamp (timestamp-now)
    (offset :hour *session-duration-hours*)))

(defun authenticate-user (email password)
  "Authenticate a user by email and password. Returns a session instance on success, NIL on failure."
  (let ((user (find-user-by-email email)))
    (when (and user
               (string= (password-hash user)
                         (hash-password password)))
      (let ((session (make-instance 'session
                                    :user-id (entity-id user)
                                    :session-token (generate-session-token)
                                    :expires-at (session-expiry-time))))
        (save-session session)
        session))))

(defun validate-session (token)
  "Check if a session token is valid and not expired. Returns the user instance or NIL."
  (let ((session (find-session-by-token token)))
    (when (and session
               (local-time:timestamp> (session-expires-at session) (timestamp-now)))
      (find-user-by-id (session-user-id session)))))

(defun logout-session (token)
  "Invalidate a session by its token."
  (delete-session-by-token token))

(defun register-user (&key email password display-name (role :user))
  "Create and persist a new user. Returns the user instance."
  (let ((user (make-instance 'user
                             :email email
                             :password-hash (hash-password password)
                             :display-name display-name
                             :role role)))
    (save-user user)))

(defun update-user-by-id (id &key email display-name role password)
  "Update an existing user's fields and persist. Returns the updated user or NIL."
  (let ((user (find-user-by-id id)))
    (when user
      (when email (setf (user-email user) email))
      (when display-name (setf (display-name user) display-name))
      (when role (setf (user-role user) role))
      (when (and password (not (string= password "")))
        (setf (password-hash user) (hash-password password)))
      (touch user)
      (save-user user))))
