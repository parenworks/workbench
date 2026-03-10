(in-package #:workbench)

(defclass user (entity)
  ((email :initarg :email :accessor user-email)
   (password-hash :initarg :password-hash :accessor password-hash)
   (display-name :initarg :display-name :accessor display-name)
   (role :initarg :role :accessor user-role :initform :user)))

(defmethod validate ((obj user))
  (and (user-email obj)
       (password-hash obj)
       t))
