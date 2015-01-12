(in-package :cl-user)
(defpackage jonathan.util
  (:use :cl)
  (:import-from :jonathan.config
                :*template-directory*)
  (:import-from :caveman2
                :*response*
                :defroute)
  (:import-from :clack.response
                :headers)
  (:import-from :cl-emb
                :*escape-type*
                :*case-sensitivity*
                :*function-package*
                :execute-emb)
  (:import-from :datafly
                :encode-json)
  (:export :render
           :render-json))
(in-package :jonathan.util)

(syntax:use-syntax :annot)

(defun render (template-path &optional env)
  (let ((emb:*escape-type* :html)
        (emb:*case-sensitivity* nil))
    (emb:execute-emb
     (merge-pathnames template-path
                      *template-directory*)
     :env env)))

(defun render-json (object)
  (setf (headers *response* :content-type) "application/json")
  (encode-json object))

(defmacro define-method (method)
  (let ((name (intern (concatenate 'string (symbol-name method) "API"))))
  `(defmacro ,name (function-form)
     (let* ((func-name (cadr function-form))
            (func-args (caddr function-form))
            (func-body (cadddr function-form))
            (path-name (concatenate 'string "/api/" (string-downcase (symbol-name func-name)))))
       `(defroute ,func-name (,path-name :method ,,method) (,@func-args) (render-json ,func-body))))))

@export
(define-method :GET)

@export
(define-method :POST)

@export
(define-method :PUT)

@export
(define-method :DELETE)
