(in-package #:workbench)

(defclass entity ()
  ((id :initarg :id :accessor entity-id :initform (make-id))
   (created-at :initarg :created-at :accessor created-at :initform (timestamp-now))
   (updated-at :initarg :updated-at :accessor updated-at :initform (timestamp-now))))

(defgeneric validate (entity))
(defgeneric touch (entity))
(defgeneric display-name (entity))
(defgeneric serialize (entity))
(defgeneric can-view-p (user entity))
(defgeneric can-edit-p (user entity))

(defmethod validate ((obj entity))
  t)

(defmethod touch ((obj entity))
  (setf (updated-at obj) (timestamp-now))
  obj)

(defmethod display-name ((obj entity))
  (format nil "~A" (entity-id obj)))

(defmethod serialize ((obj entity))
  (list :id (entity-id obj)
        :created-at (created-at obj)
        :updated-at (updated-at obj)))

(defmethod can-view-p ((user t) (obj entity))
  t)

(defmethod can-edit-p ((user t) (obj entity))
  t)
