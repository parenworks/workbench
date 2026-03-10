(in-package #:workbench)

(defun define-routes ()
  "Register all Hunchentoot route handlers."

  ;; === Authentication ===

  (hunchentoot:define-easy-handler (login-page :uri "/login") ()
    (setf (hunchentoot:content-type*) "text/html")
    (if (current-user)
        (hunchentoot:redirect "/")
        (render-login-layout "Login" (render-login-form))))

  (hunchentoot:define-easy-handler (login-submit :uri "/login"
                                                 :default-request-type :post) ()
    (setf (hunchentoot:content-type*) "text/html")
    (let* ((email (hunchentoot:post-parameter "email"))
           (password (hunchentoot:post-parameter "password"))
           (form-error (validate-login-form email password)))
      (if form-error
          (render-login-layout "Login" (render-login-form :error form-error))
          (let ((session (authenticate-user email password)))
            (if session
                (progn
                  (set-session-cookie (session-token session))
                  (hunchentoot:redirect "/"))
                (render-login-layout "Login"
                                     (render-login-form :error "Invalid email or password.")))))))

  (hunchentoot:define-easy-handler (logout-submit :uri "/logout"
                                                  :default-request-type :post) ()
    (let ((token (hunchentoot:cookie-in *cookie-name*)))
      (when token (logout-session token)))
    (clear-session-cookie)
    (hunchentoot:redirect "/login"))

  ;; === Dashboard ===

  (hunchentoot:define-easy-handler (dashboard-page :uri "/") ()
    (setf (hunchentoot:content-type*) "text/html")
    (let ((user (require-login)))
      (when user
        (let ((data (dashboard-summary)))
          (render-layout "Dashboard"
                         (render-dashboard-view data)
                         :user user
                         :flash (get-flash-message))))))

  (hunchentoot:define-easy-handler (dashboard-alt :uri "/dashboard") ()
    (hunchentoot:redirect "/"))

  ;; === Clients ===

  (hunchentoot:define-easy-handler (clients-list-page :uri "/clients") ()
    (setf (hunchentoot:content-type*) "text/html")
    (let ((user (require-login)))
      (when user
        (render-layout "Clients"
                       (render-clients-list (list-clients))
                       :user user
                       :flash (get-flash-message)))))

  (hunchentoot:define-easy-handler (client-new-page :uri "/clients/new") ()
    (setf (hunchentoot:content-type*) "text/html")
    (let ((user (require-login)))
      (when user
        (render-layout "New Client"
                       (render-client-form)
                       :user user))))

  (hunchentoot:define-easy-handler (client-create :uri "/clients"
                                                  :default-request-type :post) ()
    (let ((user (require-login)))
      (when user
        (let* ((name (hunchentoot:post-parameter "name"))
               (contact-name (hunchentoot:post-parameter "contact_name"))
               (contact-email (hunchentoot:post-parameter "contact_email"))
               (notes (hunchentoot:post-parameter "notes"))
               (form-error (validate-client-form name)))
          (if form-error
              (progn
                (setf (hunchentoot:content-type*) "text/html")
                (render-layout "New Client"
                               (render-client-form :error form-error)
                               :user user))
              (let ((client (create-client :name name
                                           :contact-name contact-name
                                           :contact-email contact-email
                                           :notes notes)))
                (flash-message (format nil "Client '~A' created." (client-name client)))
                (hunchentoot:redirect (format nil "/clients/~A" (entity-id client)))))))))

  ;; === My Tasks ===

  (hunchentoot:define-easy-handler (my-tasks-page :uri "/my-tasks") ()
    (setf (hunchentoot:content-type*) "text/html")
    (let ((user (require-login)))
      (when user
        (render-layout "My Tasks"
                       (render-my-tasks (my-tasks user))
                       :user user
                       :flash (get-flash-message)))))

  ;; === Users ===

  (hunchentoot:define-easy-handler (users-list-page :uri "/users") ()
    (setf (hunchentoot:content-type*) "text/html")
    (let ((user (require-login)))
      (when user
        (render-layout "Users"
                       (render-users-list (list-users))
                       :user user
                       :flash (get-flash-message)))))

  (hunchentoot:define-easy-handler (user-new-page :uri "/users/new") ()
    (setf (hunchentoot:content-type*) "text/html")
    (let ((user (require-login)))
      (when user
        (render-layout "New User"
                       (render-user-form)
                       :user user))))

  (hunchentoot:define-easy-handler (user-create :uri "/users"
                                                :default-request-type :post) ()
    (let ((user (require-login)))
      (when user
        (let* ((display-nm (hunchentoot:post-parameter "display_name"))
               (email (hunchentoot:post-parameter "email"))
               (password (hunchentoot:post-parameter "password"))
               (role-str (hunchentoot:post-parameter "role"))
               (role (if role-str (intern (string-upcase role-str) :keyword) :user)))
          (if (or (null display-nm) (string= display-nm "")
                  (null email) (string= email "")
                  (null password) (string= password ""))
              (progn
                (setf (hunchentoot:content-type*) "text/html")
                (render-layout "New User"
                               (render-user-form :error "All fields are required.")
                               :user user))
              (let ((new-user (register-user :email email
                                             :password password
                                             :display-name display-nm
                                             :role role)))
                (flash-message (format nil "User '~A' created." (display-name new-user)))
                (hunchentoot:redirect (format nil "/users/~A" (entity-id new-user)))))))))

  ;; === Client Detail / Edit / Update (dispatch by pattern) ===

  ;; We use a single catch-all dispatcher for /clients/* paths since
  ;; Hunchentoot easy-handlers don't natively support path parameters.
  ;; This is registered at the end via push-dispatch.

  ;; === Projects ===

  (hunchentoot:define-easy-handler (projects-list-page :uri "/projects") ()
    (setf (hunchentoot:content-type*) "text/html")
    (let ((user (require-login)))
      (when user
        (render-layout "Projects"
                       (render-projects-list (list-projects))
                       :user user
                       :flash (get-flash-message)))))

  (hunchentoot:define-easy-handler (project-new-page :uri "/projects/new") ()
    (setf (hunchentoot:content-type*) "text/html")
    (let ((user (require-login)))
      (when user
        (let ((default-client-id (hunchentoot:get-parameter "client_id")))
          (render-layout "New Project"
                         (render-project-form :all-clients (list-clients)
                                              :default-client-id default-client-id)
                         :user user)))))

  (hunchentoot:define-easy-handler (project-create :uri "/projects"
                                                   :default-request-type :post) ()
    (let ((user (require-login)))
      (when user
        (let* ((name (hunchentoot:post-parameter "name"))
               (slug (hunchentoot:post-parameter "slug"))
               (client-id (hunchentoot:post-parameter "client_id"))
               (description (hunchentoot:post-parameter "description"))
               (form-error (validate-project-form name slug client-id)))
          (if form-error
              (progn
                (setf (hunchentoot:content-type*) "text/html")
                (render-layout "New Project"
                               (render-project-form :all-clients (list-clients)
                                                    :error form-error)
                               :user user))
              (let ((project (create-project :client-id client-id
                                             :name name
                                             :slug slug
                                             :description description
                                             :user user)))
                (flash-message (format nil "Project '~A' created." (project-name project)))
                (hunchentoot:redirect (format nil "/projects/~A" (entity-id project)))))))))

  (values))

;;; === Path-parameter dispatch for /clients/:id/* and /projects/:id/* ===

(defun parse-path-segments (uri prefix)
  "Given a URI like '/clients/abc/edit' and prefix '/clients/',
return the remaining segments as a list: (\"abc\" \"edit\")."
  (let ((rest (subseq uri (length prefix))))
    (remove-if (lambda (s) (string= s ""))
               (uiop:split-string rest :separator "/"))))

(defun client-dispatcher (request)
  "Dispatch /clients/:id, /clients/:id/edit, /clients/:id/update."
  (let ((uri (hunchentoot:script-name request)))
    (when (and (>= (length uri) 9)
               (string= (subseq uri 0 9) "/clients/")
               (not (string= uri "/clients/new")))
      (let* ((segments (parse-path-segments uri "/clients/"))
             (id (first segments))
             (action (second segments)))
        (lambda ()
          (let ((user (require-login)))
            (when user
              (setf (hunchentoot:content-type*) "text/html")
              (cond
                ;; POST /clients/:id/update
                ((and (string= action "update")
                      (eq (hunchentoot:request-method request) :post))
                 (let* ((name (hunchentoot:post-parameter "name"))
                        (contact-name (hunchentoot:post-parameter "contact_name"))
                        (contact-email (hunchentoot:post-parameter "contact_email"))
                        (notes (hunchentoot:post-parameter "notes"))
                        (form-error (validate-client-form name)))
                   (if form-error
                       (let ((client (find-client-by-id id)))
                         (render-layout "Edit Client"
                                        (render-client-form :client client :error form-error)
                                        :user user))
                       (progn
                         (update-client id :name name
                                          :contact-name contact-name
                                          :contact-email contact-email
                                          :notes notes)
                         (flash-message "Client updated.")
                         (hunchentoot:redirect (format nil "/clients/~A" id))))))

                ;; GET /clients/:id/edit
                ((string= action "edit")
                 (let ((client (find-client-by-id id)))
                   (if client
                       (render-layout (format nil "Edit ~A" (client-name client))
                                      (render-client-form :client client)
                                      :user user)
                       (progn (setf (hunchentoot:return-code*) 404)
                              "Not found"))))

                ;; GET /clients/:id
                ((null action)
                 (let ((data (get-client-with-projects id)))
                   (if data
                       (render-layout (client-name (getf data :client))
                                      (render-client-detail data)
                                      :user user
                                      :flash (get-flash-message))
                       (progn (setf (hunchentoot:return-code*) 404)
                              "Not found"))))

                (t nil)))))))))

(defun project-dispatcher (request)
  "Dispatch /projects/:id, /projects/:id/edit, /projects/:id/update,
/projects/:id/archive, /projects/:id/status,
/projects/:id/tasks, /projects/:id/notes, /projects/:id/activity."
  (let ((uri (hunchentoot:script-name request)))
    (when (and (>= (length uri) 10)
               (string= (subseq uri 0 10) "/projects/")
               (not (string= uri "/projects/new")))
      (let* ((segments (parse-path-segments uri "/projects/"))
             (id (first segments))
             (action (second segments)))
        (lambda ()
          (let ((user (require-login)))
            (when user
              (setf (hunchentoot:content-type*) "text/html")
              (cond
                ;; POST /projects/:id/update
                ((and (string= action "update")
                      (eq (hunchentoot:request-method request) :post))
                 (let* ((name (hunchentoot:post-parameter "name"))
                        (slug (hunchentoot:post-parameter "slug"))
                        (client-id (hunchentoot:post-parameter "client_id"))
                        (description (hunchentoot:post-parameter "description"))
                        (status-str (hunchentoot:post-parameter "status"))
                        (status (when status-str
                                  (intern (string-upcase status-str) :keyword)))
                        (form-error (validate-project-form name slug client-id)))
                   (if form-error
                       (let ((project (find-project-by-id id)))
                         (render-layout "Edit Project"
                                        (render-project-form :project project
                                                             :all-clients (list-clients)
                                                             :error form-error)
                                        :user user))
                       (progn
                         (update-project id :name name :slug slug
                                           :description description
                                           :status status
                                           :user user)
                         (flash-message "Project updated.")
                         (hunchentoot:redirect (format nil "/projects/~A" id))))))

                ;; GET /projects/:id/edit
                ((string= action "edit")
                 (let ((project (find-project-by-id id)))
                   (if project
                       (render-layout (format nil "Edit ~A" (project-name project))
                                      (render-project-form :project project
                                                           :all-clients (list-clients))
                                      :user user)
                       (progn (setf (hunchentoot:return-code*) 404)
                              "Not found"))))

                ;; POST /projects/:id/archive
                ((and (string= action "archive")
                      (eq (hunchentoot:request-method request) :post))
                 (archive-project-by-id id user)
                 (flash-message "Project archived.")
                 (hunchentoot:redirect (format nil "/projects/~A" id)))

                ;; POST /projects/:id/tasks
                ((and (string= action "tasks")
                      (eq (hunchentoot:request-method request) :post))
                 (let* ((title (hunchentoot:post-parameter "title"))
                        (priority-str (hunchentoot:post-parameter "priority"))
                        (priority (when priority-str
                                    (intern (string-upcase priority-str) :keyword)))
                        (form-error (validate-task-form title)))
                   (if form-error
                       (progn
                         (flash-message form-error)
                         (hunchentoot:redirect (format nil "/projects/~A" id)))
                       (progn
                         (create-task :project-id id
                                      :title title
                                      :priority priority
                                      :user user)
                         (hunchentoot:redirect (format nil "/projects/~A" id))))))

                ;; POST /projects/:id/notes
                ((and (string= action "notes")
                      (eq (hunchentoot:request-method request) :post))
                 (let* ((body (hunchentoot:post-parameter "body"))
                        (form-error (validate-note-form body)))
                   (if form-error
                       (progn
                         (flash-message form-error)
                         (hunchentoot:redirect (format nil "/projects/~A" id)))
                       (let ((project (find-project-by-id id)))
                         (when project
                           (let ((note (add-note project user body)))
                             (save-note note)
                             (save-activity-event
                              (record-event project user :note-added
                                            :data "Note added"))))
                         (hunchentoot:redirect (format nil "/projects/~A" id))))))

                ;; GET /projects/:id
                ((null action)
                 (let ((data (get-project-detail id)))
                   (if data
                       (render-layout (project-name (getf data :project))
                                      (render-project-detail data)
                                      :user user
                                      :flash (get-flash-message))
                       (progn (setf (hunchentoot:return-code*) 404)
                              "Not found"))))

                (t nil)))))))))

(defun task-dispatcher (request)
  "Dispatch /tasks/:id, /tasks/:id/edit, /tasks/:id/update,
/tasks/:id/complete, /tasks/:id/reopen, /tasks/:id/assign."
  (let ((uri (hunchentoot:script-name request)))
    (when (and (>= (length uri) 7)
               (string= (subseq uri 0 7) "/tasks/"))
      (let* ((segments (parse-path-segments uri "/tasks/"))
             (id (first segments))
             (action (second segments)))
        (lambda ()
          (let ((user (require-login)))
            (when user
              (setf (hunchentoot:content-type*) "text/html")
              (cond
                ;; POST /tasks/:id/complete
                ((and (string= action "complete")
                      (eq (hunchentoot:request-method request) :post))
                 (let ((task (find-task-by-id id)))
                   (when task
                     (complete-task-by-id id user)
                     (hunchentoot:redirect
                      (format nil "/projects/~A" (task-project-id task))))))

                ;; POST /tasks/:id/reopen
                ((and (string= action "reopen")
                      (eq (hunchentoot:request-method request) :post))
                 (let ((task (find-task-by-id id)))
                   (when task
                     (reopen-task-by-id id user)
                     (hunchentoot:redirect
                      (format nil "/projects/~A" (task-project-id task))))))

                ;; POST /tasks/:id/assign
                ((and (string= action "assign")
                      (eq (hunchentoot:request-method request) :post))
                 (let* ((assignee-id (hunchentoot:post-parameter "assignee_id"))
                        (aid (if (or (null assignee-id) (string= assignee-id ""))
                                 nil assignee-id)))
                   (update-task-by-id id :assignee-id (or aid "") :user user)
                   (hunchentoot:redirect (format nil "/tasks/~A" id))))

                ;; POST /tasks/:id/update
                ((and (string= action "update")
                      (eq (hunchentoot:request-method request) :post))
                 (let* ((title (hunchentoot:post-parameter "title"))
                        (description (hunchentoot:post-parameter "description"))
                        (priority-str (hunchentoot:post-parameter "priority"))
                        (priority (when priority-str
                                    (intern (string-upcase priority-str) :keyword)))
                        (status-str (hunchentoot:post-parameter "status"))
                        (status (when status-str
                                  (intern (string-upcase status-str) :keyword)))
                        (assignee-id (hunchentoot:post-parameter "assignee_id"))
                        (due-date-str (hunchentoot:post-parameter "due_date"))
                        (due-date (when (and due-date-str (not (string= due-date-str "")))
                                    (local-time:parse-timestring due-date-str)))
                        (form-error (validate-task-form title)))
                   (if form-error
                       (let ((data (get-task-detail id)))
                         (render-layout "Edit Task"
                                        (render-task-form :task (getf data :task)
                                                          :project (getf data :project)
                                                          :all-users (getf data :all-users)
                                                          :error form-error)
                                        :user user))
                       (progn
                         (update-task-by-id id
                                            :title title
                                            :description description
                                            :priority priority
                                            :status status
                                            :assignee-id (if (or (null assignee-id)
                                                                  (string= assignee-id ""))
                                                              nil assignee-id)
                                            :due-date due-date
                                            :user user)
                         (flash-message "Task updated.")
                         (hunchentoot:redirect (format nil "/tasks/~A" id))))))

                ;; GET /tasks/:id/edit
                ((string= action "edit")
                 (let ((data (get-task-detail id)))
                   (if data
                       (render-layout (format nil "Edit ~A" (task-title (getf data :task)))
                                      (render-task-form :task (getf data :task)
                                                        :project (getf data :project)
                                                        :all-users (getf data :all-users))
                                      :user user)
                       (progn (setf (hunchentoot:return-code*) 404)
                              "Not found"))))

                ;; GET /tasks/:id
                ((null action)
                 (let ((data (get-task-detail id)))
                   (if data
                       (render-layout (task-title (getf data :task))
                                      (render-task-detail data)
                                      :user user
                                      :flash (get-flash-message))
                       (progn (setf (hunchentoot:return-code*) 404)
                              "Not found"))))

                (t nil)))))))))

(defun user-dispatcher (request)
  "Dispatch /users/:id, /users/:id/edit, /users/:id/update."
  (let ((uri (hunchentoot:script-name request)))
    (when (and (>= (length uri) 7)
               (string= (subseq uri 0 7) "/users/")
               (not (string= uri "/users/new")))
      (let* ((segments (parse-path-segments uri "/users/"))
             (id (first segments))
             (action (second segments)))
        (lambda ()
          (let ((user (require-login)))
            (when user
              (setf (hunchentoot:content-type*) "text/html")
              (cond
                ;; POST /users/:id/update
                ((and (string= action "update")
                      (eq (hunchentoot:request-method request) :post))
                 (let* ((display-nm (hunchentoot:post-parameter "display_name"))
                        (email (hunchentoot:post-parameter "email"))
                        (role-str (hunchentoot:post-parameter "role"))
                        (role (when role-str (intern (string-upcase role-str) :keyword)))
                        (password (hunchentoot:post-parameter "password")))
                   (if (or (null display-nm) (string= display-nm "")
                           (null email) (string= email ""))
                       (let ((target-user (find-user-by-id id)))
                         (render-layout "Edit User"
                                        (render-user-form :user-obj target-user
                                                          :error "Name and email are required.")
                                        :user user))
                       (progn
                         (update-user-by-id id :display-name display-nm
                                               :email email
                                               :role role
                                               :password password)
                         (flash-message "User updated.")
                         (hunchentoot:redirect (format nil "/users/~A" id))))))

                ;; GET /users/:id/edit
                ((string= action "edit")
                 (let ((target-user (find-user-by-id id)))
                   (if target-user
                       (render-layout (format nil "Edit ~A" (display-name target-user))
                                      (render-user-form :user-obj target-user)
                                      :user user)
                       (progn (setf (hunchentoot:return-code*) 404)
                              "Not found"))))

                ;; GET /users/:id
                ((null action)
                 (let ((target-user (find-user-by-id id)))
                   (if target-user
                       (render-layout (display-name target-user)
                                      (render-user-detail target-user)
                                      :user user
                                      :flash (get-flash-message))
                       (progn (setf (hunchentoot:return-code*) 404)
                              "Not found"))))

                (t nil)))))))))

(defun register-dispatchers ()
  "Register custom dispatchers for path-parameter routes."
  (pushnew 'client-dispatcher hunchentoot:*dispatch-table* :test #'eq)
  (pushnew 'project-dispatcher hunchentoot:*dispatch-table* :test #'eq)
  (pushnew 'task-dispatcher hunchentoot:*dispatch-table* :test #'eq)
  (pushnew 'user-dispatcher hunchentoot:*dispatch-table* :test #'eq))
