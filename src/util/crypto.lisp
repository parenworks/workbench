(in-package #:workbench)

(defun hash-password (password)
  "Starter placeholder password hashing function.
Replace with a stronger password hashing approach before production use."
  (ironclad:byte-array-to-hex-string
   (ironclad:digest-sequence :sha256
                             (ironclad:ascii-string-to-byte-array password))))
