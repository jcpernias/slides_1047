(package-initialize)
(setq package-enable-at-startup nil)
(require 'use-package)
(use-package org)


(require 'ox-beamer)

;; Template for hyperref package options.
;; This format string may contain these elements:

;;   %a for AUTHOR keyword
;;   %t for TITLE keyword
;;   %s for SUBTITLE keyword
;;   %k for KEYWORDS line
;;   %d for DESCRIPTION line
;;   %c for CREATOR line
;;   %l for Language keyword
;;   %L for capitalized language keyword
;;   %D for DATE keyword

;; If you need to use a "%" character, you need to escape it
;; like that: "%%".

;; As a special case, a nil value prevents template from being
;; inserted.

(setq org-latex-hyperref-template
      "\\AtEndPreamble{\\hypersetup{%%
 pdfauthor={%a},%%
 pdftitle={%t},%%
 pdfkeywords={%k},%%
 pdfsubject={%d},%%
 pdfcreator={%c},%%
 pdflang={%L}}}
")

(setq docs-labq-class
      '("labq"
        "\\documentclass{labq}
[NO-DEFAULT-PACKAGES]
[EXTRA]
[NO-PACKAGES]"
        ("\\section{%s}" . "\\section*{%s}")
        ("\\subsection{%s}" . "\\subsection*{%s}")))


(setq docs-exam-class
      '("exam"
        "\\documentclass{exam}
[NO-DEFAULT-PACKAGES]
[EXTRA]
[NO-PACKAGES]"
        ("\\section{%s}" . "\\section*{%s}")
        ("\\subsection{%s}" . "\\subsection*{%s}")))


(setq docs-probl-class
      '("probl"
        "\\documentclass{probl}
[NO-DEFAULT-PACKAGES]
[EXTRA]
[NO-PACKAGES]"
        ("\\section{%s}" . "\\section*{%s}")
        ("\\subsection{%s}" . "\\subsection*{%s}")))

(setq docs-syllabus-class
      '("syllabus"
        "\\documentclass{syllabus}
\\usepackage[AUTO]{inputenc}
[NO-DEFAULT-PACKAGES]
[EXTRA]
[NO-PACKAGES]"
        ("\\section{%s}" . "\\section*{%s}")
        ("\\subsection{%s}" . "\\subsection*{%s}")
        ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
        ("\\paragraph{%s}" . "\\paragraph*{%s}")
        ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

(setq docs-unit-class
      '("unit"
        "\\documentclass{unit}
[NO-DEFAULT-PACKAGES]
[EXTRA]
[NO-PACKAGES]"
        ("\\section{%s}" . "\\section*{%s}")
        ("\\subsection{%s}" . "\\subsection*{%s}")))


(defun install-custom-class (description)
  "Make a LaTeX class available to use with Org"
  (let ((class (car description)))
    (unless (assoc class org-latex-classes)
      (add-to-list 'org-latex-classes description))))


(defun uninstall-custom-class (class)
  "Remove the given LaTeX class from the list of classes
available to use with Org"
  (interactive "sClass: ")
  (let (elem)
    (setq elem (assoc class org-latex-classes))
    (if elem
        (setq org-latex-classes
              (delq elem org-latex-classes)))))


(install-custom-class docs-labq-class)
(install-custom-class docs-exam-class)
(install-custom-class docs-probl-class)
(install-custom-class docs-syllabus-class)
(install-custom-class docs-unit-class)

;; Export settings
;; --------------------------------------------------------------------------------

(setq org-latex-image-default-width "")
(setq org-list-allow-alphabetical t)

;; Allow opening question or exclamation marks before emphasis
;; Allow matches spanning 5 lines
(setcar org-emphasis-regexp-components " \t('\"{¿¡[")
(setcar (nthcdr 4 org-emphasis-regexp-components) 2)
(org-set-emph-re 'org-emphasis-regexp-components org-emphasis-regexp-components)


;; Do not insert a default Beamer theme
(setq org-beamer-theme nil)

;; Support of csquotes package
(add-to-list
 'org-export-smart-quotes-alist
 '("en"
   (primary-opening :utf-8 "“" :html "&ldquo;" :latex "\\enquote{" :texinfo "``")
   (primary-closing :utf-8 "”" :html "&rdquo;" :latex "}" :texinfo "''")
   (secondary-opening :utf-8 "‘" :html "&lsquo;" :latex "\\enquote*{" :texinfo "`")
   (secondary-closing :utf-8 "’" :html "&rsquo;" :latex "}" :texinfo "'")
   (apostrophe :utf-8 "’" :html "&rsquo;")))

(add-to-list
 'org-export-smart-quotes-alist
 '("es"
   (primary-opening :utf-8 "«" :html "&laquo;" :latex "\\enquote{" :texinfo "@guillemetleft{}")
   (primary-closing :utf-8 "»" :html "&raquo;" :latex "}" :texinfo "@guillemetright{}")
   (secondary-opening :utf-8 "“" :html "&ldquo;" :latex "\\enquote*{" :texinfo "``")
   (secondary-closing :utf-8 "”" :html "&rdquo;" :latex "}" :texinfo "''")
   (apostrophe :utf-8 "’" :html "&rsquo;")))



;; Export functions
;; --------------------------------------------------------------------------------

(defun tolatex (&optional dir)
  "Export current org buffer to a latex file in directory DIR."
  (interactive "DDirectory: ")
  (let ((name (file-name-base (buffer-file-name))))
    (org-latex-export-as-latex)
    (write-file (concat dir name ".tex"))))

(defun tobeamer (&optional dir)
  "Export current org buffer to a latex file in directory DIR."
  (interactive "DDirectory: ")
  (let ((name (file-name-base (buffer-file-name))))
    (org-beamer-export-as-latex)
    (write-file (concat dir name ".tex"))))


;; Babel
;; --------------------------------------------------------------------------------

(defun my-org-confirm-babel-evaluate (lang body)
  (not (string-match "^\\(R\\|emacs-lisp\\)$" lang)))
(setq org-confirm-babel-evaluate 'my-org-confirm-babel-evaluate)
(setq ess-ask-for-ess-directory nil)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (shell . t)
   (R . t)
   (python . t)
   (latex . t)
   (ditaa . t)))

(add-to-list 'org-src-lang-modes
   '("r" . R))

(defun tangle (file dir)
  (find-file (expand-file-name file))
  (cd (expand-file-name dir))
  (org-babel-tangle)
  (kill-buffer))

(defun tangle-to (dir)
  (cd (expand-file-name dir))
  (org-babel-tangle))
