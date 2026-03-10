(in-package #:workbench)

;;; --- Helper formatters ---

(defun format-relative-time (timestamp)
  "Format a timestamp as a relative time string."
  (if (null timestamp)
      ""
      (let* ((now (timestamp-now))
             (diff (local-time:timestamp-difference now timestamp))
             (minutes (floor diff 60))
             (hours (floor minutes 60))
             (days (floor hours 24)))
        (cond
          ((< minutes 1) "just now")
          ((< minutes 60) (format nil "~Dm ago" minutes))
          ((< hours 24) (format nil "~Dh ago" hours))
          ((< days 30) (format nil "~Dd ago" days))
          (t (format-timestamp timestamp))))))

(defun status-badge-class (status)
  "Return the CSS class for a status badge."
  (let ((s (string-downcase (symbol-name status))))
    (format nil "badge badge-~A" s)))

(defun priority-badge-class (priority)
  "Return the CSS class for a priority badge."
  (let ((p (string-downcase (symbol-name priority))))
    (format nil "badge badge-~A" p)))

;;; --- Login View ---

(defun render-login-form (&key error)
  "Render the login form HTML."
  (with-html-output-to-string (s)
    (:form :method "post" :action "/login" :class "login-form"
           (when error
             (htm (:div :class "flash-message flash-error" (str error))))
           (:div :class "form-group"
                 (:label :class "form-label" :for "email" "Email")
                 (:input :type "email" :name "email" :id "email"
                         :class "form-input" :required t
                         :placeholder "you@example.com"))
           (:div :class "form-group"
                 (:label :class "form-label" :for "password" "Password")
                 (:input :type "password" :name "password" :id "password"
                         :class "form-input" :required t
                         :placeholder "Password"))
           (:div :class "form-actions"
                 (:button :type "submit" :class "btn btn-primary" "Log in")))))

;;; --- Dashboard View ---

(defun render-dashboard-view (data)
  "Render the dashboard body HTML."
  (let ((open-count (getf data :open-projects))
        (overdue (getf data :overdue-tasks))
        (activity (getf data :recent-activity))
        (projects (getf data :recent-projects)))
    (with-html-output-to-string (s)
      ;; Stat cards
      (:div :class "dashboard-grid"
            (:div :class "stat-card"
                  (:div :class "stat-value" (str open-count))
                  (:div :class "stat-label" "Active Projects"))
            (:div :class "stat-card"
                  (:div :class "stat-value" (str (length overdue)))
                  (:div :class "stat-label" "Overdue Tasks")))

      ;; Recent projects
      (:div :class "section-header"
            (:h2 :class "section-title" "Active Projects"))
      (if projects
          (htm
           (:table
            (:thead
             (:tr (:th "Project") (:th "Status") (:th "Updated")))
            (:tbody
             (dolist (p projects)
               (htm
                (:tr
                 (:td (:a :href (format nil "/projects/~A" (entity-id p))
                          (str (project-name p))))
                 (:td (:span :class (status-badge-class (project-status p))
                             (str (string-downcase (symbol-name (project-status p))))))
                 (:td (str (format-relative-time (updated-at p))))))))))
          (htm (:div :class "empty-state" "No active projects yet.")))

      ;; Recent activity
      (:div :class "section-header"
            (:h2 :class "section-title" "Recent Activity"))
      (if activity
          (htm
           (:ul :class "timeline"
                (dolist (evt activity)
                  (htm
                   (:li :class "timeline-item"
                        (:span :class "timeline-time"
                               (str (format-relative-time (created-at evt))))
                        (:span :class "timeline-content"
                               (str (or (event-data evt)
                                        (string-downcase (symbol-name (event-type evt)))))))))))
          (htm (:div :class "empty-state" "No activity yet."))))))

;;; --- Clients Views ---

(defun render-clients-list (clients)
  "Render the clients list page body."
  (with-html-output-to-string (s)
    (:div :class "section-header"
          (:span)
          (:a :href "/clients/new" :class "btn btn-primary" "New Client"))
    (:div :class "search-bar"
          (:input :type "text" :class "search-input" :placeholder "Search clients..."))
    (if clients
        (htm
         (:table
          (:thead
           (:tr (:th "Name") (:th "Contact") (:th "Email") (:th "Projects")))
          (:tbody
           (dolist (c clients)
             (let ((project-count (length (list-projects-for-client (entity-id c)))))
               (htm
                (:tr
                 (:td (:a :href (format nil "/clients/~A" (entity-id c))
                          (str (client-name c))))
                 (:td (str (or (contact-name c) "")))
                 (:td (str (or (contact-email c) "")))
                 (:td (str project-count)))))))))
        (htm (:div :class "empty-state" "No clients yet. Create one to get started.")))))

(defun render-client-form (&key client clients-for-select error)
  "Render the client create/edit form."
  (declare (ignore clients-for-select))
  (let ((editing (not (null client))))
    (with-html-output-to-string (s)
      (when error
        (htm (:div :class "flash-message flash-error" (str error))))
      (:form :method "post"
             :action (if editing
                         (format nil "/clients/~A/update" (entity-id client))
                         "/clients")
             (:div :class "form-group"
                   (:label :class "form-label" :for "name" "Client Name")
                   (:input :type "text" :name "name" :id "name"
                           :class "form-input" :required t
                           :value (if editing (client-name client) "")))
             (:div :class "form-group"
                   (:label :class "form-label" :for "contact_name" "Contact Name")
                   (:input :type "text" :name "contact_name" :id "contact_name"
                           :class "form-input"
                           :value (if editing (or (contact-name client) "") "")))
             (:div :class "form-group"
                   (:label :class "form-label" :for "contact_email" "Contact Email")
                   (:input :type "email" :name "contact_email" :id "contact_email"
                           :class "form-input"
                           :value (if editing (or (contact-email client) "") "")))
             (:div :class "form-group"
                   (:label :class "form-label" :for "notes" "Notes")
                   (:textarea :name "notes" :id "notes"
                              :class "form-textarea"
                              (str (if editing (or (client-notes client) "") ""))))
             (:div :class "form-actions"
                   (:button :type "submit" :class "btn btn-primary"
                            (str (if editing "Update Client" "Create Client")))
                   (:a :href (if editing
                                  (format nil "/clients/~A" (entity-id client))
                                  "/clients")
                       :class "btn" "Cancel"))))))

(defun render-client-detail (data)
  "Render the client detail page body."
  (let ((client (getf data :client))
        (projects (getf data :projects)))
    (with-html-output-to-string (s)
      (:div :class "card"
            (:div :class "detail-grid"
                  (:div
                   (:div :class "detail-label" "Contact Name")
                   (:div :class "detail-value" (str (or (contact-name client) "—"))))
                  (:div
                   (:div :class "detail-label" "Contact Email")
                   (:div :class "detail-value" (str (or (contact-email client) "—")))))
            (when (client-notes client)
              (htm
               (:div :style "margin-top: 1rem"
                     (:div :class "detail-label" "Notes")
                     (:div :class "detail-value" (str (client-notes client))))))
            (:div :class "form-actions"
                  (:a :href (format nil "/clients/~A/edit" (entity-id client))
                      :class "btn" "Edit Client")))

      ;; Projects for this client
      (:div :class "section-header"
            (:h2 :class "section-title" "Projects")
            (:a :href (format nil "/projects/new?client_id=~A" (entity-id client))
                :class "btn btn-small btn-primary" "New Project"))
      (if projects
          (htm
           (:table
            (:thead
             (:tr (:th "Project") (:th "Status") (:th "Updated")))
            (:tbody
             (dolist (p projects)
               (htm
                (:tr
                 (:td (:a :href (format nil "/projects/~A" (entity-id p))
                          (str (project-name p))))
                 (:td (:span :class (status-badge-class (project-status p))
                             (str (string-downcase (symbol-name (project-status p))))))
                 (:td (str (format-relative-time (updated-at p))))))))))
          (htm (:div :class "empty-state" "No projects for this client yet."))))))

;;; --- Projects Views ---

(defun render-projects-list (projects)
  "Render the projects list page body."
  (with-html-output-to-string (s)
    (:div :class "section-header"
          (:span)
          (:a :href "/projects/new" :class "btn btn-primary" "New Project"))
    (:div :class "search-bar"
          (:input :type "text" :class "search-input" :placeholder "Search projects..."))
    (if projects
        (htm
         (:table
          (:thead
           (:tr (:th "Project") (:th "Client") (:th "Status") (:th "Updated")))
          (:tbody
           (dolist (p projects)
             (let ((client (find-client-by-id (project-client-id p))))
               (htm
                (:tr
                 (:td (:a :href (format nil "/projects/~A" (entity-id p))
                          (str (project-name p))))
                 (:td (if client
                          (htm (:a :href (format nil "/clients/~A" (entity-id client))
                                   (str (client-name client))))
                          (htm (str "—"))))
                 (:td (:span :class (status-badge-class (project-status p))
                             (str (string-downcase (symbol-name (project-status p))))))
                 (:td (str (format-relative-time (updated-at p)))))))))))
        (htm (:div :class "empty-state" "No projects yet. Create one to get started.")))))

(defun render-project-form (&key project all-clients error default-client-id)
  "Render the project create/edit form."
  (let ((editing (not (null project))))
    (with-html-output-to-string (s)
      (when error
        (htm (:div :class "flash-message flash-error" (str error))))
      (:form :method "post"
             :action (if editing
                         (format nil "/projects/~A/update" (entity-id project))
                         "/projects")
             (:div :class "form-group"
                   (:label :class "form-label" :for "name" "Project Name")
                   (:input :type "text" :name "name" :id "name"
                           :class "form-input" :required t
                           :value (if editing (project-name project) "")))
             (:div :class "form-group"
                   (:label :class "form-label" :for "slug" "Slug")
                   (:input :type "text" :name "slug" :id "slug"
                           :class "form-input" :required t
                           :value (if editing (project-slug project) "")
                           :placeholder "project-slug"))
             (:div :class "form-group"
                   (:label :class "form-label" :for "client_id" "Client")
                   (:select :name "client_id" :id "client_id" :class "form-select" :required t
                            (:option :value "" "Select a client...")
                            (dolist (c all-clients)
                              (let ((selected-id (if editing
                                                     (project-client-id project)
                                                     default-client-id)))
                                (if (and selected-id (string= (entity-id c) selected-id))
                                    (htm (:option :value (entity-id c) :selected "selected"
                                                  (str (client-name c))))
                                    (htm (:option :value (entity-id c)
                                                  (str (client-name c)))))))))
             (when editing
               (htm
                (:div :class "form-group"
                      (:label :class "form-label" :for "status" "Status")
                      (:select :name "status" :id "status" :class "form-select"
                               (dolist (st '(:active :on-hold :completed :archived))
                                 (if (eq st (project-status project))
                                     (htm (:option :value (string-downcase (symbol-name st))
                                                   :selected "selected"
                                                   (str (string-downcase (symbol-name st)))))
                                     (htm (:option :value (string-downcase (symbol-name st))
                                                   (str (string-downcase (symbol-name st)))))))))))
             (:div :class "form-group"
                   (:label :class "form-label" :for "description" "Description")
                   (:textarea :name "description" :id "description"
                              :class "form-textarea"
                              (str (if editing (project-description project) ""))))
             (:div :class "form-actions"
                   (:button :type "submit" :class "btn btn-primary"
                            (str (if editing "Update Project" "Create Project")))
                   (:a :href (if editing
                                  (format nil "/projects/~A" (entity-id project))
                                  "/projects")
                       :class "btn" "Cancel"))))))

(defun render-project-detail (data)
  "Render the project detail page body."
  (let ((project (getf data :project))
        (client (getf data :client))
        (tasks (getf data :tasks))
        (notes (getf data :notes))
        (activity (getf data :activity)))
    (with-html-output-to-string (s)
      ;; Project info card
      (:div :class "card"
            (:div :class "card-header"
                  (:span :class (status-badge-class (project-status project))
                         (str (string-downcase (symbol-name (project-status project)))))
                  (:div
                   (:a :href (format nil "/projects/~A/edit" (entity-id project))
                       :class "btn btn-small" "Edit")))
            (:div :class "detail-grid"
                  (:div
                   (:div :class "detail-label" "Client")
                   (:div :class "detail-value"
                         (if client
                             (htm (:a :href (format nil "/clients/~A" (entity-id client))
                                      (str (client-name client))))
                             (htm (str "—")))))
                  (:div
                   (:div :class "detail-label" "Slug")
                   (:div :class "detail-value" (str (project-slug project)))))
            (when (and (project-description project)
                       (not (string= (project-description project) "")))
              (htm
               (:div :style "margin-top: 1rem"
                     (:div :class "detail-label" "Description")
                     (:div :class "detail-value" (str (project-description project)))))))

      ;; Tasks section
      (:div :class "section-header"
            (:h2 :class "section-title" "Tasks")
            (:span))
      ;; Add task form
      (:div :class "card"
            (:form :method "post" :action (format nil "/projects/~A/tasks" (entity-id project))
                   :style "display: flex; gap: 0.5rem; align-items: end"
                   (:div :style "flex: 1"
                         (:input :type "text" :name "title" :class "form-input"
                                 :placeholder "Add a task..." :required t))
                   (:select :name "priority" :class "form-select" :style "width: auto"
                            (:option :value "normal" "Normal")
                            (:option :value "high" "High")
                            (:option :value "low" "Low"))
                   (:button :type "submit" :class "btn btn-primary btn-small" "Add")))
      (if tasks
          (htm
           (:div :class "card"
                 (dolist (task tasks)
                   (let ((assignee (when (task-assignee-id task)
                                     (find-user-by-id (task-assignee-id task)))))
                     (htm
                      (:div :class "task-item"
                            (:div :class "task-info"
                                  (:span :class (priority-badge-class (task-priority task))
                                         (str (string-downcase (symbol-name (task-priority task)))))
                                  (:a :href (format nil "/tasks/~A" (entity-id task))
                                      :style (if (eq (task-status task) :done)
                                                 "text-decoration: line-through; color: #6b7280"
                                                 "")
                                      (str (task-title task)))
                                  (when assignee
                                    (htm (:span :class "badge badge-normal"
                                                :style "margin-left: 0.5rem; font-size: 0.7rem"
                                                (str (display-name assignee))))))
                            (:div :class "task-actions"
                                  (:span :class (status-badge-class (task-status task))
                                         (str (string-downcase (symbol-name (task-status task)))))
                                  (if (eq (task-status task) :done)
                                      (htm
                                       (:form :method "post"
                                              :action (format nil "/tasks/~A/reopen" (entity-id task))
                                              :class "inline-form"
                                              (:button :type "submit" :class "btn btn-small btn-ghost"
                                                       "Reopen")))
                                      (htm
                                       (:form :method "post"
                                              :action (format nil "/tasks/~A/complete" (entity-id task))
                                              :class "inline-form"
                                              (:button :type "submit" :class "btn btn-small"
                                                       "Complete")))))))))))
          (htm (:div :class "empty-state" "No tasks yet.")))

      ;; Notes section
      (:div :class "section-header"
            (:h2 :class "section-title" "Notes")
            (:span))
      ;; Add note form
      (:div :class "card"
            (:form :method "post" :action (format nil "/projects/~A/notes" (entity-id project))
                   (:textarea :name "body" :class "form-textarea"
                              :placeholder "Add a note..." :required t
                              :rows "3")
                   (:div :class "form-actions"
                         (:button :type "submit" :class "btn btn-primary btn-small" "Add Note"))))
      (if notes
          (htm
           (dolist (note notes)
             (htm
              (:div :class "note-item"
                    (:div :class "note-meta"
                          (str (format-relative-time (created-at note))))
                    (:div :class "note-body"
                          (str (note-body note)))))))
          (htm (:div :class "empty-state" "No notes yet.")))

      ;; Activity timeline
      (:div :class "section-header"
            (:h2 :class "section-title" "Activity"))
      (if activity
          (htm
           (:ul :class "timeline"
                (dolist (evt activity)
                  (htm
                   (:li :class "timeline-item"
                        (:span :class "timeline-time"
                               (str (format-relative-time (created-at evt))))
                        (:span :class "timeline-content"
                               (str (or (event-data evt)
                                        (string-downcase (symbol-name (event-type evt)))))))))))
          (htm (:div :class "empty-state" "No activity yet."))))))

;;; --- Task Detail & Edit Views ---

(defun render-task-detail (data)
  "Render the task detail page body."
  (let ((task (getf data :task))
        (project (getf data :project))
        (assignee (getf data :assignee))
        (all-users (getf data :all-users)))
    (with-html-output-to-string (s)
      (:div :class "card"
            (:div :class "card-header"
                  (:div
                   (:span :class (status-badge-class (task-status task))
                          (str (string-downcase (symbol-name (task-status task)))))
                   (:span :class (priority-badge-class (task-priority task))
                          :style "margin-left: 0.5rem"
                          (str (string-downcase (symbol-name (task-priority task))))))
                  (:div
                   (:a :href (format nil "/tasks/~A/edit" (entity-id task))
                       :class "btn btn-small" "Edit")
                   (if (eq (task-status task) :done)
                       (htm
                        (:form :method "post"
                               :action (format nil "/tasks/~A/reopen" (entity-id task))
                               :class "inline-form"
                               :style "margin-left: 0.5rem"
                               (:button :type "submit" :class "btn btn-small btn-ghost" "Reopen")))
                       (htm
                        (:form :method "post"
                               :action (format nil "/tasks/~A/complete" (entity-id task))
                               :class "inline-form"
                               :style "margin-left: 0.5rem"
                               (:button :type "submit" :class "btn btn-small btn-primary" "Complete"))))))
            (:div :class "detail-grid"
                  (:div
                   (:div :class "detail-label" "Project")
                   (:div :class "detail-value"
                         (if project
                             (htm (:a :href (format nil "/projects/~A" (entity-id project))
                                      (str (project-name project))))
                             (htm (str "—")))))
                  (:div
                   (:div :class "detail-label" "Assigned To")
                   (:div :class "detail-value"
                         (if assignee
                             (htm (str (display-name assignee)))
                             (htm (:span :style "color: #6b7280" "Unassigned")))))
                  (:div
                   (:div :class "detail-label" "Due Date")
                   (:div :class "detail-value"
                         (if (task-due-date task)
                             (htm (str (format-timestamp (task-due-date task))))
                             (htm (:span :style "color: #6b7280" "None")))))
                  (:div
                   (:div :class "detail-label" "Created")
                   (:div :class "detail-value"
                         (str (format-relative-time (created-at task))))))
            (when (and (task-description task)
                       (not (string= (task-description task) "")))
              (htm
               (:div :style "margin-top: 1rem"
                     (:div :class "detail-label" "Description")
                     (:div :class "detail-value" :style "white-space: pre-wrap"
                           (str (task-description task)))))))

      ;; Quick assign form
      (:div :class "card"
            (:div :class "card-title" :style "margin-bottom: 0.75rem" "Quick Assign")
            (:form :method "post" :action (format nil "/tasks/~A/assign" (entity-id task))
                   :style "display: flex; gap: 0.5rem; align-items: end"
                   (:select :name "assignee_id" :class "form-select" :style "flex: 1"
                            (:option :value "" "Unassigned")
                            (dolist (u all-users)
                              (if (and assignee (string= (entity-id u) (entity-id assignee)))
                                  (htm (:option :value (entity-id u) :selected "selected"
                                                (str (display-name u))))
                                  (htm (:option :value (entity-id u)
                                                (str (display-name u)))))))
                   (:button :type "submit" :class "btn btn-primary btn-small" "Assign"))))))

(defun render-task-form (&key task project all-users error)
  "Render the task edit form."
  (declare (ignore project))
  (with-html-output-to-string (s)
    (when error
      (htm (:div :class "flash-message flash-error" (str error))))
    (:form :method "post"
           :action (format nil "/tasks/~A/update" (entity-id task))
           (:div :class "form-group"
                 (:label :class "form-label" :for "title" "Title")
                 (:input :type "text" :name "title" :id "title"
                         :class "form-input" :required t
                         :value (task-title task)))
           (:div :class "form-group"
                 (:label :class "form-label" :for "description" "Description")
                 (:textarea :name "description" :id "description"
                            :class "form-textarea"
                            (str (or (task-description task) ""))))
           (:div :class "form-group"
                 (:label :class "form-label" :for "priority" "Priority")
                 (:select :name "priority" :id "priority" :class "form-select"
                          (dolist (p '(:high :normal :low))
                            (if (eq p (task-priority task))
                                (htm (:option :value (string-downcase (symbol-name p))
                                              :selected "selected"
                                              (str (string-downcase (symbol-name p)))))
                                (htm (:option :value (string-downcase (symbol-name p))
                                              (str (string-downcase (symbol-name p)))))))))
           (:div :class "form-group"
                 (:label :class "form-label" :for "status" "Status")
                 (:select :name "status" :id "status" :class "form-select"
                          (dolist (st '(:open :done))
                            (if (eq st (task-status task))
                                (htm (:option :value (string-downcase (symbol-name st))
                                              :selected "selected"
                                              (str (string-downcase (symbol-name st)))))
                                (htm (:option :value (string-downcase (symbol-name st))
                                              (str (string-downcase (symbol-name st)))))))))
           (:div :class "form-group"
                 (:label :class "form-label" :for "assignee_id" "Assigned To")
                 (:select :name "assignee_id" :id "assignee_id" :class "form-select"
                          (:option :value "" "Unassigned")
                          (dolist (u all-users)
                            (if (and (task-assignee-id task)
                                     (string= (entity-id u) (task-assignee-id task)))
                                (htm (:option :value (entity-id u) :selected "selected"
                                              (str (display-name u))))
                                (htm (:option :value (entity-id u)
                                              (str (display-name u))))))))
           (:div :class "form-group"
                 (:label :class "form-label" :for "due_date" "Due Date")
                 (:input :type "date" :name "due_date" :id "due_date"
                         :class "form-input"
                         :value (if (task-due-date task)
                                    (local-time:format-timestring
                                     nil (task-due-date task)
                                     :format '((:year 4) #\- (:month 2) #\- (:day 2)))
                                    "")))
           (:div :class "form-actions"
                 (:button :type "submit" :class "btn btn-primary" "Update Task")
                 (:a :href (format nil "/tasks/~A" (entity-id task))
                     :class "btn" "Cancel")))))

;;; --- My Tasks View ---

(defun render-my-tasks (tasks)
  "Render the 'My Tasks' page body showing tasks assigned to the current user."
  (with-html-output-to-string (s)
    (if tasks
        (htm
         (:table
          (:thead
           (:tr (:th "Task") (:th "Project") (:th "Priority") (:th "Due Date") (:th "Status")))
          (:tbody
           (dolist (task tasks)
             (let ((project (find-project-by-id (task-project-id task))))
               (htm
                (:tr
                 (:td (:a :href (format nil "/tasks/~A" (entity-id task))
                          (str (task-title task))))
                 (:td (if project
                          (htm (:a :href (format nil "/projects/~A" (entity-id project))
                                   (str (project-name project))))
                          (htm (str "—"))))
                 (:td (:span :class (priority-badge-class (task-priority task))
                             (str (string-downcase (symbol-name (task-priority task))))))
                 (:td (if (task-due-date task)
                          (htm (str (format-timestamp (task-due-date task))))
                          (htm (str "—"))))
                 (:td (:span :class (status-badge-class (task-status task))
                             (str (string-downcase (symbol-name (task-status task)))))))))))))
        (htm (:div :class "empty-state" "No tasks assigned to you.")))))

;;; --- User Management Views ---

(defun render-users-list (users)
  "Render the users list page body."
  (with-html-output-to-string (s)
    (:div :class "section-header"
          (:span)
          (:a :href "/users/new" :class "btn btn-primary" "New User"))
    (if users
        (htm
         (:table
          (:thead
           (:tr (:th "Name") (:th "Email") (:th "Role") (:th "Created")))
          (:tbody
           (dolist (u users)
             (htm
              (:tr
               (:td (:a :href (format nil "/users/~A" (entity-id u))
                        (str (or (display-name u) (user-email u)))))
               (:td (str (user-email u)))
               (:td (:span :class "badge badge-normal"
                           (str (string-downcase (symbol-name (user-role u))))))
               (:td (str (format-relative-time (created-at u))))))))))
        (htm (:div :class "empty-state" "No users yet.")))))

(defun render-user-form (&key user-obj error)
  "Render the user create/edit form."
  (let ((editing (not (null user-obj))))
    (with-html-output-to-string (s)
      (when error
        (htm (:div :class "flash-message flash-error" (str error))))
      (:form :method "post"
             :action (if editing
                         (format nil "/users/~A/update" (entity-id user-obj))
                         "/users")
             (:div :class "form-group"
                   (:label :class "form-label" :for "display_name" "Display Name")
                   (:input :type "text" :name "display_name" :id "display_name"
                           :class "form-input" :required t
                           :value (if editing (or (display-name user-obj) "") "")))
             (:div :class "form-group"
                   (:label :class "form-label" :for "email" "Email")
                   (:input :type "email" :name "email" :id "email"
                           :class "form-input" :required t
                           :value (if editing (user-email user-obj) "")))
             (:div :class "form-group"
                   (:label :class "form-label" :for "role" "Role")
                   (:select :name "role" :id "role" :class "form-select"
                            (dolist (r '(:user :admin))
                              (if (and editing (eq r (user-role user-obj)))
                                  (htm (:option :value (string-downcase (symbol-name r))
                                                :selected "selected"
                                                (str (string-downcase (symbol-name r)))))
                                  (htm (:option :value (string-downcase (symbol-name r))
                                                (str (string-downcase (symbol-name r)))))))))
             (:div :class "form-group"
                   (:label :class "form-label" :for "password"
                           (str (if editing "Password (leave blank to keep)" "Password")))
                   (:input :type "password" :name "password" :id "password"
                           :class "form-input"
                           :required (unless editing t)))
             (:div :class "form-actions"
                   (:button :type "submit" :class "btn btn-primary"
                            (str (if editing "Update User" "Create User")))
                   (:a :href (if editing
                                  (format nil "/users/~A" (entity-id user-obj))
                                  "/users")
                       :class "btn" "Cancel"))))))

(defun render-user-detail (user-obj)
  "Render the user detail page body."
  (let ((assigned-tasks (list-tasks-for-user (entity-id user-obj))))
    (with-html-output-to-string (s)
      (:div :class "card"
            (:div :class "detail-grid"
                  (:div
                   (:div :class "detail-label" "Email")
                   (:div :class "detail-value" (str (user-email user-obj))))
                  (:div
                   (:div :class "detail-label" "Role")
                   (:div :class "detail-value"
                         (:span :class "badge badge-normal"
                                (str (string-downcase (symbol-name (user-role user-obj)))))))
                  (:div
                   (:div :class "detail-label" "Member Since")
                   (:div :class "detail-value" (str (format-relative-time (created-at user-obj))))))
            (:div :class "form-actions"
                  (:a :href (format nil "/users/~A/edit" (entity-id user-obj))
                      :class "btn" "Edit User")))

      ;; Assigned tasks
      (:div :class "section-header"
            (:h2 :class "section-title" "Assigned Tasks"))
      (if assigned-tasks
          (htm
           (:div :class "card"
                 (dolist (task assigned-tasks)
                   (let ((project (find-project-by-id (task-project-id task))))
                     (htm
                      (:div :class "task-item"
                            (:div :class "task-info"
                                  (:span :class (priority-badge-class (task-priority task))
                                         (str (string-downcase (symbol-name (task-priority task)))))
                                  (:a :href (format nil "/tasks/~A" (entity-id task))
                                      (str (task-title task)))
                                  (when project
                                    (htm (:span :style "margin-left: 0.5rem; color: #6b7280; font-size: 0.8rem"
                                                (str (project-name project))))))
                            (:div :class "task-actions"
                                  (:span :class (status-badge-class (task-status task))
                                         (str (string-downcase (symbol-name (task-status task))))))))))))
          (htm (:div :class "empty-state" "No tasks assigned to this user."))))))
