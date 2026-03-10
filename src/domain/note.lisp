(in-package #:workbench)

(defclass project-note (entity)
  ((project-id :initarg :project-id :accessor note-project-id)
   (user-id :initarg :user-id :accessor note-user-id)
   (body :initarg :body :accessor note-body)))

(defmethod validate ((obj project-note))
  (and (note-project-id obj)
       (note-user-id obj)
       (note-body obj)
       t))

(defmethod add-note ((project project) (user user) body)
  (make-instance 'project-note
                 :project-id (entity-id project)
                 :user-id (entity-id user)
                 :body body))
