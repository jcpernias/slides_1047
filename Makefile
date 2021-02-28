SHELL := /bin/sh

subject_code := 1047
units := \
	Intro \
	Size \
	Welfare \
	Market-Failure \
	Efficiency-Equity \
	Public-Goods \
	Externalities \
	Cost-Benefit

unit_figs := \
	Welfare \
	Efficiency-Equity \
	Public-Goods \
	Externalities

LANGUAGES := es
DOC_TYPES := hdout pres

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

emacsbin := /usr/local/bin/emacs
texi2dvibin := /usr/local/opt/texinfo/bin/texi2dvi
envbin  := /usr/local/opt/coreutils/libexec/gnubin/env
pythonbin := /usr/local/bin/python3
Rscriptbin := /usr/local/bin/Rscript

## Variables
## ================================================================================

EMACS := $(emacsbin) -Q -nw --batch
emacs_loads := --load=$(elispdir)/setup-org.el \
	--load=$(elispdir)/mats.el
org_to_latex := --eval "(tolatex (file-name-as-directory \"$(builddir)\"))"
org_to_beamer := --eval "(tobeamer (file-name-as-directory \"$(builddir)\"))"
tangle := --eval "(tangle-to (file-name-as-directory \"$(builddir)\"))"

LATEX_OUTPUT := no
TEXI2DVI_FLAGS := --batch $(TEXI2DVI_SILENT) -I $(texdir) --pdf \
	--build=tidy --build-dir=$(notdir $(builddir))

ifneq ($(LATEX_OUTPUT), yes)
TEXI2DVI_FLAGS += -q
endif

TEXI2DVI := $(envbin) TEXI2DVI_USE_RECORDER=yes \
	$(texi2dvibin) $(TEXI2DVI_FLAGS)

MAKEORGDEPS := $(pythonbin) $(pythondir)/makeorgdeps.py
MAKETEXDEPS := $(pythonbin) $(pythondir)/maketexdeps.py
MAKEFIGDEPS := $(pythonbin) $(pythondir)/makefigdeps.py

RSCRIPT := $(Rscriptbin) -e

docs_suffixes := $(addprefix _$(subject_code)-, $(LANGUAGES))
docs_prefixes := $(foreach type,$(DOC_TYPES),$(addprefix $(type)-,$(units)))
docs_base := $(foreach suffix,$(docs_suffixes),$(addsuffix $(suffix),$(docs_prefixes)))

docs_pdf := $(addprefix $(outdir)/, $(addsuffix .pdf, $(docs_base)))

real_rootdir := $(realpath $(rootdir))
tex_check_dirs := $(builddir) $(figdir) $(depsdir)

## Automatic dependencies
## ================================================================================
docs_deps := $(addprefix $(depsdir)/, $(addsuffix .pdf.d, $(docs_base)))

tex_deps_base := $(foreach suffix,$(docs_suffixes),$(addsuffix $(suffix),$(units)))
tex_deps := $(addprefix $(depsdir)/unit-, $(addsuffix .tex.d, $(tex_deps_base)))

unit_figs_deps := $(addprefix $(depsdir)/unit-,\
	$(addsuffix _$(subject_code)-figs.d, $(unit_figs)))

all_deps := $(docs_deps) $(tex_deps) $(unit_figs_deps)


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
\InputIfFileExists{unit-$3-macros.tex}{}{}
\begin{document}
\input{$(realpath $(builddir))/fig-$2}
\end{document}
endef


# $(call knit,in,out)
define knit
"source(\"./R/common.R\"); library(knitr); options(knitr.package.root.dir=\"${rootdir}\"); knit(\"$1\", \"$2\")"
endef

vpath %.pdf $(figdir)
vpath %.png $(imgdir)
vpath %.jpg $(imgdir)

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

$(builddir)/pres-%.tex: $(builddir)/unit-%.tex | $(figdir)
	$(file > $@,$(call tex-wrapper,Presentation,$(call get-unit,$*),$(call get-lang,$*)))

$(builddir)/hdout-%.tex: $(builddir)/unit-%.tex | $(figdir)
	$(file > $@,$(call tex-wrapper,Handout,$(call get-unit,$*),$(call get-lang,$*)))

.PRECIOUS: $(builddir)/pres-%.tex
.PRECIOUS: $(builddir)/hdout-%.tex





## latex to pdf
$(outdir)/%.pdf: $(builddir)/%.tex | $(outdir)
	$(TEXI2DVI) --output=$@ $<

# pdf dependencies
$(depsdir)/%.pdf.d: $(builddir)/%.tex | $(outdir) $(depsdir)
	$(MAKETEXDEPS) -o $@ -t $(outdir)/$*.pdf $<

# figure wrappers
.PRECIOUS: $(builddir)/fig-%-en.tex
$(builddir)/fig-%-en.tex: $(builddir)/fig-%.tex
	$(file > $@, $(call fig-wrapper,English,$*,$(shell echo $* | sed 's/\([^-]*\)-.*/\1/')))

.PRECIOUS: $(builddir)/fig-%-es.tex
$(builddir)/fig-%-es.tex: $(builddir)/fig-%.tex
	$(file > $@, $(call fig-wrapper,Spanish,$*,$(shell echo $* | sed 's/\([^-]*\)-.*/\1/')))

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
