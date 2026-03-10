(in-package #:workbench)

(defun current-user ()
  "Get the current authenticated user from the session cookie, or NIL."
  (let ((token (hunchentoot:cookie-in *cookie-name*)))
    (when token
      (validate-session token))))

(defun require-login ()
  "Check if the user is logged in. If not, redirect to /login.
Returns the user object if authenticated."
  (let ((user (current-user)))
    (unless user
      (hunchentoot:redirect "/login"))
    user))

(defun set-session-cookie (token)
  "Set the session cookie in the response."
  (hunchentoot:set-cookie *cookie-name*
                          :value token
                          :path "/"
                          :http-only t))

(defun clear-session-cookie ()
  "Clear the session cookie."
  (hunchentoot:set-cookie *cookie-name*
                          :value ""
                          :path "/"
                          :max-age 0
                          :http-only t))

(defun flash-message (message)
  "Store a flash message in the session for the next request."
  (setf (hunchentoot:session-value :flash) message))

(defun get-flash-message ()
  "Retrieve and clear the flash message."
  (let ((msg (hunchentoot:session-value :flash)))
    (when msg
      (hunchentoot:delete-session-value :flash))
    msg))
