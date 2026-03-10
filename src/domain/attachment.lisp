(in-package #:workbench)

(defclass attachment (entity)
  ((project-id :initarg :project-id :accessor attachment-project-id)
   (filename :initarg :filename :accessor attachment-filename)
   (storage-path :initarg :storage-path :accessor attachment-storage-path)
   (mime-type :initarg :mime-type :accessor attachment-mime-type)))

(defmethod validate ((obj attachment))
  (and (attachment-project-id obj)
       (attachment-filename obj)
       (attachment-storage-path obj)
       t))
