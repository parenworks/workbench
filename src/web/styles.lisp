(in-package #:workbench)

(defun generate-css ()
  "Generate the application CSS using LASS and write it to static/css/workbench.css."
  (let ((css-path (merge-pathnames "static/css/workbench.css"
                                   (asdf:system-source-directory "workbench"))))
    (ensure-directories-exist css-path)
    (with-open-file (out css-path :direction :output :if-exists :supersede)
      (write-string (compile-stylesheet) out))
    (format t "~&CSS written to ~A~%" css-path)
    css-path))

(defun compile-stylesheet ()
  "Compile the LASS stylesheet to a CSS string."
  (lass:compile-and-write

   ;; === Reset & Base ===
   '(:* :box-sizing border-box :margin 0 :padding 0)

   '((:or html body)
     :font-family "'Inter', 'SF Pro Text', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif"
     :font-size 15px
     :line-height 1.6
     :color "#e0e0e0"
     :background "#0f1117")

   '(a :color "#7eb8da" :text-decoration none)
   '((:and a :hover) :color "#a8d4f0" :text-decoration underline)

   ;; === Navigation ===
   '(.main-nav
     :display flex
     :align-items center
     :justify-content space-between
     :padding "0.75rem 2rem"
     :background "#161822"
     :border-bottom "1px solid #262836")

   '(.nav-brand
     (a :color "#e0e0e0"
        :font-weight 700
        :font-size "1.1rem"
        :letter-spacing "0.04em"
        :text-decoration none))

   '(.nav-links
     :display flex
     :gap "1.5rem"
     (a :color "#9ca3af"
        :font-size "0.9rem"
        :text-decoration none)
     ((:and a :hover) :color "#e0e0e0"))

   '(.nav-user
     :display flex
     :align-items center
     :gap "1rem")

   '(.user-name
     :color "#9ca3af"
     :font-size "0.85rem")

   '(.inline-form :display inline)

   ;; === Container ===
   '(.container
     :max-width 960px
     :margin "0 auto"
     :padding "2rem")

   ;; === Page Title ===
   '(.page-title
     :font-size "1.5rem"
     :font-weight 600
     :margin-bottom "1.5rem"
     :color "#f0f0f0")

   ;; === Flash Messages ===
   '(.flash-message
     :padding "0.75rem 1rem"
     :margin-bottom "1.5rem"
     :border-radius 6px
     :background "#1a2332"
     :border "1px solid #264060"
     :color "#7eb8da"
     :font-size "0.9rem")

   '(.flash-error
     :background "#2a1a1a"
     :border-color "#5a2020"
     :color "#e07070")

   ;; === Buttons ===
   '(.btn
     :display inline-flex
     :align-items center
     :padding "0.5rem 1rem"
     :border-radius 5px
     :border "1px solid #363846"
     :background "#1e2030"
     :color "#e0e0e0"
     :font-size "0.85rem"
     :cursor pointer
     :transition "all 0.15s ease")

   '((:and .btn :hover)
     :background "#2a2c40"
     :border-color "#4a4c60")

   '(.btn-primary
     :background "#2563a0"
     :border-color "#2563a0"
     :color "#ffffff")

   '((:and .btn-primary :hover)
     :background "#2d72b5")

   '(.btn-small
     :padding "0.3rem 0.6rem"
     :font-size "0.8rem")

   '(.btn-ghost
     :background transparent
     :border-color transparent
     :color "#9ca3af")

   '((:and .btn-ghost :hover)
     :color "#e0e0e0"
     :background "#1e2030")

   '(.btn-danger
     :background "#7a2020"
     :border-color "#7a2020"
     :color "#ffffff")

   '((:and .btn-danger :hover)
     :background "#952a2a")

   ;; === Cards ===
   '(.card
     :background "#161822"
     :border "1px solid #262836"
     :border-radius 8px
     :padding "1.25rem"
     :margin-bottom "1rem")

   '(.card-header
     :display flex
     :justify-content space-between
     :align-items center
     :margin-bottom "0.75rem")

   '(.card-title
     :font-size "1rem"
     :font-weight 600
     :color "#f0f0f0")

   ;; === Dashboard ===
   '(.dashboard-grid
     :display grid
     :grid-template-columns "repeat(auto-fit, minmax(200px, 1fr))"
     :gap "1rem"
     :margin-bottom "2rem")

   '(.stat-card
     :background "#161822"
     :border "1px solid #262836"
     :border-radius 8px
     :padding "1.25rem"
     :text-align center)

   '(.stat-value
     :font-size "2rem"
     :font-weight 700
     :color "#7eb8da")

   '(.stat-label
     :font-size "0.85rem"
     :color "#9ca3af"
     :margin-top "0.25rem")

   ;; === Tables ===
   '(table
     :width "100%"
     :border-collapse collapse)

   '((:or th td)
     :padding "0.75rem 1rem"
     :text-align left
     :border-bottom "1px solid #262836")

   '(th
     :font-weight 600
     :color "#9ca3af"
     :font-size "0.8rem"
     :text-transform uppercase
     :letter-spacing "0.05em")

   '((:and tr :hover)
     :background "#1a1c2e")

   ;; === Status Badges ===
   '(.badge
     :display inline-block
     :padding "0.2rem 0.6rem"
     :border-radius 12px
     :font-size "0.75rem"
     :font-weight 600
     :text-transform uppercase
     :letter-spacing "0.03em")

   '(.badge-active :background "#1a3320" :color "#4ade80")
   '(.badge-archived :background "#2a2020" :color "#9ca3af")
   '(.badge-on-hold :background "#2a2a10" :color "#eab308")
   '(.badge-open :background "#1a2332" :color "#7eb8da")
   '(.badge-done :background "#1a3320" :color "#4ade80")
   '(.badge-high :background "#2a1a1a" :color "#e07070")
   '(.badge-normal :background "#1a2332" :color "#7eb8da")
   '(.badge-low :background "#1e2030" :color "#9ca3af")

   ;; === Forms ===
   '(.form-group
     :margin-bottom "1rem")

   '(.form-label
     :display block
     :font-size "0.85rem"
     :color "#9ca3af"
     :margin-bottom "0.35rem"
     :font-weight 500)

   '((:or .form-input .form-textarea .form-select)
     :width "100%"
     :padding "0.6rem 0.75rem"
     :background "#0f1117"
     :border "1px solid #363846"
     :border-radius 5px
     :color "#e0e0e0"
     :font-size "0.9rem"
     :font-family inherit)

   '((:and (:or .form-input .form-textarea .form-select) :focus)
     :outline none
     :border-color "#2563a0"
     :box-shadow "0 0 0 2px rgba(37, 99, 160, 0.25)")

   '(.form-textarea
     :min-height 100px
     :resize vertical)

   '(.form-actions
     :display flex
     :gap "0.75rem"
     :margin-top "1.5rem")

   ;; === Login Page ===
   '(.login-page
     :display flex
     :flex-direction column
     :min-height "100vh"
     :justify-content center
     :align-items center)

   '(.login-container
     :width 360px
     :padding "2rem")

   '(.login-brand
     :font-size "1.5rem"
     :font-weight 700
     :text-align center
     :margin-bottom "2rem"
     :color "#f0f0f0")

   '(.login-form
     (.form-input :background "#161822"))

   ;; === Section Headers ===
   '(.section-header
     :display flex
     :justify-content space-between
     :align-items center
     :margin-bottom "1rem"
     :margin-top "2rem")

   '(.section-title
     :font-size "1.1rem"
     :font-weight 600
     :color "#f0f0f0")

   ;; === Activity Timeline ===
   '(.timeline
     :list-style none)

   '(.timeline-item
     :padding "0.75rem 0"
     :border-bottom "1px solid #1e2030"
     :display flex
     :gap "0.75rem"
     :font-size "0.9rem")

   '(.timeline-time
     :color "#6b7280"
     :font-size "0.8rem"
     :white-space nowrap
     :min-width 140px)

   '(.timeline-content
     :color "#c0c0c0")

   ;; === Task List ===
   '(.task-item
     :display flex
     :align-items center
     :justify-content space-between
     :padding "0.6rem 0"
     :border-bottom "1px solid #1e2030")

   '(.task-info
     :display flex
     :align-items center
     :gap "0.75rem")

   '(.task-actions
     :display flex
     :gap "0.5rem")

   ;; === Note ===
   '(.note-item
     :padding "1rem"
     :margin-bottom "0.75rem"
     :background "#0f1117"
     :border "1px solid #1e2030"
     :border-radius 6px)

   '(.note-meta
     :font-size "0.8rem"
     :color "#6b7280"
     :margin-bottom "0.5rem")

   '(.note-body
     :color "#c0c0c0"
     :white-space pre-wrap)

   ;; === Search Bar ===
   '(.search-bar
     :margin-bottom "1.5rem"
     :display flex
     :gap "0.5rem")

   '(.search-input
     :flex 1
     :padding "0.5rem 0.75rem"
     :background "#0f1117"
     :border "1px solid #363846"
     :border-radius 5px
     :color "#e0e0e0"
     :font-size "0.9rem")

   ;; === Empty States ===
   '(.empty-state
     :text-align center
     :padding "3rem 1rem"
     :color "#6b7280")

   ;; === Footer ===
   '(.main-footer
     :text-align center
     :padding "2rem"
     :color "#4b5060"
     :font-size "0.8rem"
     :border-top "1px solid #1e2030"
     :margin-top "3rem")

   ;; === Detail Grid ===
   '(.detail-grid
     :display grid
     :grid-template-columns "1fr 1fr"
     :gap "1rem")

   '(.detail-label
     :font-size "0.8rem"
     :color "#6b7280"
     :text-transform uppercase
     :letter-spacing "0.05em")

   '(.detail-value
     :color "#e0e0e0"
     :margin-top "0.25rem")))
