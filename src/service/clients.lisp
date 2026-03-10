(in-package #:workbench)

(defun create-client (&key name contact-name contact-email notes)
  "Create and persist a new client. Returns the client instance."
  (let ((client (make-instance 'client
                               :name name
                               :contact-name contact-name
                               :contact-email contact-email
                               :notes notes)))
    (save-client client)))

(defun update-client (id &key name contact-name contact-email notes)
  "Update an existing client's fields and persist. Returns the updated client or NIL."
  (let ((client (find-client-by-id id)))
    (when client
      (when name (setf (client-name client) name))
      (when contact-name (setf (contact-name client) contact-name))
      (when contact-email (setf (contact-email client) contact-email))
      (when notes (setf (client-notes client) notes))
      (touch client)
      (save-client client))))

(defun get-client-with-projects (id)
  "Return a client and its associated projects as a plist."
  (let ((client (find-client-by-id id)))
    (when client
      (list :client client
            :projects (list-projects-for-client id)))))
