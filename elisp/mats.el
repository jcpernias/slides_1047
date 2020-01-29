;; Utility functions for Org documents
;; --------------------------------------------------------------------------------
(defun in-commented-tree (element)
  "Check if ELEMENT is part of a commented tree"
  (let ((parents (org-element-lineage element nil t))
        (comment nil))
    (while (and (not comment) parents)
      (setq element (car parents))
      (when (eq (org-element-type element) 'headline)
        (setq comment (org-element-property :commentedp element)))
      (setq parents (cdr parents)))
    comment))

(defun get-current-level (element)
  "Get the level to which ELEMENT belongs"
  (let ((headline (org-element-lineage element '(headline) t)))
    (if headline
        (org-element-property :level headline)
      0)))


(defun delete-comments (doc)
  "Remove comments and comment blocks from Org document DOC"
    (org-element-map doc '(comment comment-block) 'org-element-extract-element))

(defun make-par-link (type path affiliated post-blank)
  "Returns an Org paragraph with a link"
  (org-element-create 'paragraph
                      (list :post-blank post-blank)
                      affiliated
                      (org-element-create
                       'link (list :type type
                                   :path path))))


(defun get-affiliated (element)
  (buffer-substring (org-element-property :begin element)
                    (org-element-property :post-affiliated element)))

(defun get-post-blank (element)
  (org-element-property :post-blank element))


;; ================================================================================
;; MATS keywords
;; ================================================================================

;; Driver
;; --------------------------------------------------------------------------------
(defun process-mats-keywords (doc)
  "Get the different parts of a MATS keyword and call the appropriate handler"
  (org-element-map doc 'keyword
    (lambda (keyword)
      (let ((type)
            (text)
            (value))
        (when (and (string= (org-element-property :key keyword) "MATS")
                   (not (in-commented-tree keyword)))
          (setq text (org-element-property :value keyword))
          (when (string-match
                 "[[:blank:]]*\\([^[:blank:]]+\\)\\(?:[[:blank:]]+\\(.*\\)\\)?[[:blank:]]*\\'" text)
            (setq type (match-string 1 text)
                  value (match-string 2 text))
            (cond ((string= type "col") (handle-col keyword value))
                  ((string= type "fig") (handle-fig keyword value))
                  ((string= type "figcol") (handle-figcol keyword value))
                  ((string= type "bib") (handle-bib keyword value))
                  ((string= type "pagebreak") (handle-pagebreak keyword value))
                  (t nil))))))))

;; Handlers
;; --------------------------------------------------------------------------------

(defun handle-bib (element value)
  "Handle bibliography blocks"
  (org-element-set-element
   element
   ;; Create a new top-level headline with properties
   (org-element-create
    'headline
    (list :level 1
          :post-blank (get-post-blank element))
    (org-element-create
     'property-drawer nil
     (org-element-create
      'node-property
      (list :key "BEAMER_env" :value "fullframe"))
     (org-element-create
      'node-property
      (list :key "UNNUMBERED" :value "t"))))))

(defun handle-pagebreak (element value)
  "Handle page breaks in handouts"
  (org-element-set-element
   element
   (org-element-create                  ;; Empty headline
    'headline
    (list :level (get-current-level element)
          :post-blank (get-post-blank element))
    (org-element-create                 ;; ignoreheading property
     'property-drawer nil
     (org-element-create
      'node-property
      (list :key "BEAMER_env" :value "ignoreheading")))
    (org-element-create                  ;; latex code
     'keyword
     (list :key "latex"
           :value "\\mode<article>{\\clearpage{}}")))))

;; Handling columns

(defvar mats-col-regex
  "\\`[[:blank:]]*\\(?:\\([0-9.]+\\)[[:blank:]]*\\)?\\'")

(defun make-col (level width post-blank)
  (org-element-create
   'headline
   (list :level level
         :post-blank post-blank)
   (org-element-create 'property-drawer nil
                       (org-element-create
                        'node-property
                        (list :key "BEAMER_col" :value (format "%g" width))))))

(defun handle-col (element value)
  "Handle column"
  (let ((width))
    (when (string-match mats-col-regex value)
      (setq width (string-to-number (or (match-string 1 value) "0.5")))
      (org-element-set-element
       element
       (make-col (+ (get-current-level element) 1)
                 width
                 (get-post-blank element))))))

;; Figures

(defun fig-file-path (value lang)
  (if (string-match "\\*" value)
      (replace-match (or lang "\\LANG") nil t value)
    value))

(defun handle-fig (element value)
  (org-element-set-element
   element
   (make-par-link "file"
                  ;; (concat "./figures/" (fig-file-path value nil))
                  (fig-file-path value nil)
                  (get-affiliated element)
                  (get-post-blank element))))


(defun handle-figcol (element value)
  (let ((args)
        (path)
        (width)
        (level)
        (new))
    (setq args (split-string value))
    (setq path (fig-file-path (pop args) nil))
    (setq width (string-to-number (or (pop args) "0.5")))
    (setq level (+ (get-current-level element) 1))
    (setq new (make-col level width 1))
    (org-element-adopt-elements
        new (make-par-link "file"
                           path
                           (get-affiliated element) 1))
    (org-element-insert-before new element)
    (org-element-set-element
     element (make-col level (- 1 width) (get-post-blank element)))))

;; ================================================================================
;; Install driver
;; ================================================================================

(defun prepare-buffer ()
  "Remove comments and substitute MATS keywords"
  (let ((doc (org-element-parse-buffer)))
    (delete-comments doc)
    (process-mats-keywords doc)
    (org-element-interpret-data doc)))

(defun mats-preprocess (backend)
  "Replace buffer contents after substitute MATS keywords"
  (let ((new (prepare-buffer)))
    (erase-buffer)
    (insert new)))

(add-hook 'org-export-before-parsing-hook 'mats-preprocess)
