(in-package #:workbench)

(defclass client (entity)
  ((name :initarg :name :accessor client-name)
   (contact-name :initarg :contact-name :accessor contact-name :initform nil)
   (contact-email :initarg :contact-email :accessor contact-email :initform nil)
   (notes :initarg :notes :accessor client-notes :initform nil)))

(defmethod display-name ((obj client))
  (client-name obj))

(defmethod validate ((obj client))
  (and (client-name obj) t))
