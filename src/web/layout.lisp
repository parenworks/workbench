(in-package #:workbench)

(setf (cl-who:html-mode) :html5)

(defun render-layout (title body-html &key user flash)
  "Render a full HTML page with navigation, optional flash message, and body content."
  (with-html-output-to-string (s nil :prologue t)
    (:html
     (:head
      (:meta :charset "utf-8")
      (:meta :name "viewport" :content "width=device-width, initial-scale=1")
      (:title (fmt "~A — ~A" title *app-name*))
      (:link :rel "stylesheet" :href "/css/workbench.css")
      (:script :src "/js/workbench.js"))
     (:body
      (when user
        (htm
         (:nav :class "main-nav"
               (:div :class "nav-brand"
                     (:a :href "/" (str *app-name*)))
               (:div :class "nav-links"
                     (:a :href "/" "Dashboard")
                     (:a :href "/clients" "Clients")
                     (:a :href "/projects" "Projects")
                     (:a :href "/my-tasks" "My Tasks")
                     (:a :href "/users" "Users"))
               (:div :class "nav-user"
                     (:span :class "user-name" (str (display-name user)))
                     (:form :method "post" :action "/logout" :class "inline-form"
                            (:button :type "submit" :class "btn btn-small btn-ghost" "Logout"))))))
      (:main :class "container"
             (when flash
               (htm (:div :class "flash-message" (str flash))))
             (:h1 :class "page-title" (str title))
             (str body-html))
      (:footer :class "main-footer"
               (:p (fmt "~A v0.1.0" *app-name*)))))))

(defun render-login-layout (title body-html &key flash)
  "Render a minimal layout for the login page (no navigation)."
  (with-html-output-to-string (s nil :prologue t)
    (:html
     (:head
      (:meta :charset "utf-8")
      (:meta :name "viewport" :content "width=device-width, initial-scale=1")
      (:title (fmt "~A — ~A" title *app-name*))
      (:link :rel "stylesheet" :href "/css/workbench.css"))
     (:body :class "login-page"
            (:main :class "login-container"
                   (when flash
                     (htm (:div :class "flash-message flash-error" (str flash))))
                   (:h1 :class "login-brand" (str *app-name*))
                   (str body-html))
            (:footer :class "main-footer"
                     (:p (fmt "~A v0.1.0" *app-name*)))))))
