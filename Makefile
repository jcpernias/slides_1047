SHELL := /bin/sh

## Directories
## ================================================================================

rootdir := .
builddir := $(rootdir)/build
outdir := $(rootdir)/pdf
elispdir := $(rootdir)/elisp
pythondir := $(rootdir)/python
Rdir := $(rootdir)/R
texdir := $(rootdir)/tex
depsdir := $(rootdir)/.deps
imgdir := $(rootdir)/img
figdir := $(rootdir)/figures


## Programs
## ================================================================================

emacsbin := /usr/bin/emacs
texi2dvibin := /usr/bin/texi2dvi
envbin  := /usr/bin/env
pythonbin := /usr/bin/python3
Rscriptbin := /usr/local/bin/Rscript

-include local.mk

## Variables
## ================================================================================

EMACS := $(emacsbin) -Q -nw --batch
emacs_loads := --load=$(elispdir)/setup-org.el \
	--load=$(elispdir)/mats.el
org_to_latex := --eval "(tolatex (file-name-as-directory \"$(builddir)\"))"
org_to_beamer := --eval "(tobeamer (file-name-as-directory \"$(builddir)\"))"
tangle := --eval "(tangle-to (file-name-as-directory \"$(builddir)\"))"

LATEX_MESSAGES := no
TEXI2DVI_FLAGS := --batch -I $(texdir) --pdf \
	--build=tidy --build-dir=$(notdir $(builddir))

ifneq ($(LATEX_MESSAGES), yes)
TEXI2DVI_FLAGS += -q
endif

TEXI2DVI := $(envbin) TEXI2DVI_USE_RECORDER=yes \
	$(texi2dvibin) $(TEXI2DVI_FLAGS)

MAKEORGDEPS := $(pythonbin) $(pythondir)/makeorgdeps.py
MAKETEXDEPS := $(pythonbin) $(pythondir)/maketexdeps.py
MAKEFIGDEPS := $(pythonbin) $(pythondir)/makefigdeps.py

RSCRIPT := $(Rscriptbin) -e

tex_check_dirs := $(builddir) $(figdir) $(depsdir)


FIGURES :=

INCLUDEDEPS := yes

# Do not include dependency files if make goal is some kind of clean
ifneq (,$(findstring clean,$(MAKECMDGOALS)))
INCLUDEDEPS := no
endif

# $(call tex-wrapper,pres-or-hdout,tex-src,lang) -> write to a file
define tex-wrapper
\PassOptionsToClass{$1}{unit}
\RequirePackage{etoolbox}
\AtEndPreamble{%
  \graphicspath{{$(realpath $(figdir))/}{$(realpath $(imgdir))/}}%
  \InputIfFileExists{$(subject_code)-macros.tex}{}{}%
  \InputIfFileExists{unit-$2_$(subject_code)-macros.tex}{}{}}
\input{$(realpath $(builddir))/unit-$2_$(subject_code)-$3}
endef

# $(call tex-wrapper,spanish-or-english,fig-basename,unit-code) -> write to a file
define fig-wrapper
\documentclass[$1]{figure}
\graphicspath{{$(realpath $(figdir))/}{$(realpath $(imgdir))/}}
\InputIfFileExists{$(subject_code)-macros.tex}{}{}
\InputIfFileExists{unit-$3_$(subject_code)-macros.tex}{}{}
\begin{document}
\input{$(realpath $(builddir))/fig-$2}
\end{document}
endef


# $(call knit,in,out)
define knit
"source(\"./R/common.R\"); library(knitr); options(knitr.package.root.dir=\"${rootdir}\"); knit(\"$1\", \"$2\")"
endef

include course.mk

## Rules
## ================================================================================

all: $(docs_pdf)

# org to latex
.PRECIOUS: $(builddir)/%.tex
$(builddir)/%.tex: $(rootdir)/%.org | $(builddir)
	$(EMACS) $(emacs_loads) --visit=$< $(org_to_beamer)

# dependencies for latex file
$(depsdir)/%.tex.d: $(rootdir)/%.org | $(depsdir)
	$(MAKEORGDEPS) -o $@ -t $(builddir)/$*.tex $<

# latex wrappers
get-unit = $(shell echo $(1) | sed 's/\([^_]*\)_.*/\1/')
get-lang = $(shell echo $(1) | sed 's/.*-\([^-]*\)/\1/')

define unit_wrapper_rule =
.PRECIOUS: $(builddir)/$(1)-%.tex
$(builddir)/$(1)-%.tex: $(builddir)/unit-%.tex | $(figdir)
	$$(file > $$@,$$(call tex-wrapper,$(1),$$(call get-unit,$$*),$$(call get-lang,$$*)))
endef

$(foreach type,$(DOC_TYPES),$(eval $(call unit_wrapper_rule,$(type))))

## latex to pdf
$(outdir)/%.pdf: $(builddir)/%.tex | $(outdir)
	$(TEXI2DVI) --output=$@ $<

# pdf dependencies
$(depsdir)/%.pdf.d: $(builddir)/%.tex | $(outdir) $(depsdir)
	$(MAKETEXDEPS) -o $@ -t $(outdir)/$*.pdf $<

# figure wrappers
define fig_wrapper_rule =
.PRECIOUS: $(builddir)/fig-%-$(1).tex
$(builddir)/fig-%-$(1).tex: $(builddir)/fig-%.tex
	$$(file > $$@,$$(call fig-wrapper,$(1),$$*,$$(call get-unit,$$*)))
endef

$(foreach lang,$(LANGUAGES),$(eval $(call fig_wrapper_rule,$(lang))))

# figure latex to pdf
$(figdir)/fig-%.pdf: $(builddir)/fig-%.tex | $(figdir)
	$(TEXI2DVI) --output=$@ $<

$(depsdir)/unit-%-figs.d: unit-%-figs.org | $(depsdir)
	$(MAKEFIGDEPS) -o $@ $<

# from R to latex
$(builddir)/%.tex: $(builddir)/%.Rnw | $(builddir)
	$(RSCRIPT) $(call knit,$<,$@)

## automatic dependencies
ifeq ($(INCLUDEDEPS),yes)
include $(all_deps)
endif

## Auxiliary directories
## --------------------------------------------------------------------------------

$(outdir):
	mkdir $(outdir)

$(builddir):
	mkdir $(builddir)

$(depsdir):
	mkdir $(depsdir)

$(figdir):
	mkdir $(figdir)

## Cleaning rules
## --------------------------------------------------------------------------------

.PHONY: clean
clean:
	-@rm -rf $(figdir)
	-@rm -rf $(builddir)
	-@rm -rf $(depsdir)

.PHONY: veryclean
veryclean: clean
	-@rm -rf $(outdir)
