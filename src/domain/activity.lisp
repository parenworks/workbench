(in-package #:workbench)

(defclass activity-event (entity)
  ((project-id :initarg :project-id :accessor event-project-id)
   (user-id :initarg :user-id :accessor event-user-id)
   (event-type :initarg :event-type :accessor event-type)
   (event-data :initarg :event-data :accessor event-data :initform nil)))

(defmethod validate ((obj activity-event))
  (and (event-project-id obj)
       (event-user-id obj)
       (event-type obj)
       t))

(defmethod record-event ((project project) (user user) event-type &key data)
  (make-instance 'activity-event
                 :project-id (entity-id project)
                 :user-id (entity-id user)
                 :event-type event-type
                 :event-data data))
