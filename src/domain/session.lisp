(in-package #:workbench)

(defclass session (entity)
  ((user-id :initarg :user-id :accessor session-user-id)
   (session-token :initarg :session-token :accessor session-token)
   (expires-at :initarg :expires-at :accessor session-expires-at)))

(defmethod validate ((obj session))
  (and (session-user-id obj)
       (session-token obj)
       (session-expires-at obj)
       t))
