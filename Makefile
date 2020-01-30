SHELL := /bin/sh

subject_code := 1047
units := Welfare Intro # 1B 1C 1D 1E 2A 2B 2C 3A 3B 4A 5A 5B 6A 6B
unit_figs := Welfare # 1B 1C 1D 1E 2A 2B 2C 3A 3B 4A 5A 5B 6A 6B

TEXI2DVI_SILENT := -q
# TEXI2DVI_SILENT :=

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

TEXI2DVI := $(envbin) TEXI2DVI_USE_RECORDER=yes \
	$(texi2dvibin) --batch $(TEXI2DVI_SILENT) \
	-I $(texdir) --pdf --build=tidy \
	--build-dir=$(notdir $(builddir))

MAKEORGDEPS := $(pythonbin) $(pythondir)/makeorgdeps.py
MAKETEXDEPS := $(pythonbin) $(pythondir)/maketexdeps.py
MAKEFIGDEPS := $(pythonbin) $(pythondir)/makefigdeps.py

RSCRIPT := $(Rscriptbin) -e

docs_es := $(addsuffix _$(subject_code)-es, \
	$(addprefix hdout-, $(units)) \
	$(addprefix pres-, $(units)))
docs_en := $(addsuffix _$(subject_code)-en, \
	$(addprefix hdout-, $(units)) \
	$(addprefix pres-, $(units)))

# TODO: Add English documents based on an variable
# docs_base := $(docs_es) $(docs_en)
docs_base := $(docs_es)
docs_pdf := $(addprefix $(outdir)/, $(addsuffix .pdf, $(docs_base)))

real_rootdir := $(realpath $(rootdir))
tex_check_dirs := $(builddir) $(figdir) $(depsdir)

## Automatic dependencies
## ================================================================================
docs_deps := $(addprefix $(depsdir)/, \
	$(addsuffix .pdf.d, $(docs_base)))


# TODO: Add English dependencies based on an variable
# tex_deps := $(addprefix $(depsdir)/unit-, \
# 	$(addsuffix _$(subject_code)-es.tex.d, $(units))) \
# 	$(addprefix $(depsdir)/unit-, \
# 	$(addsuffix _$(subject_code)-en.tex.d, $(units)))

tex_deps := $(addprefix $(depsdir)/unit-, \
	$(addsuffix _$(subject_code)-es.tex.d, $(units)))

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
\AtBeginDocument{\graphicspath{{$(realpath $(figdir))/}{$(realpath $(imgdir))/}}}
\RequirePackage{etoolbox}
\AtEndPreamble{%
  \InputIfFileExists{$(subject_code)-macros.tex}{}{}%
  \InputIfFileExists{$2-macros.tex}{}{}}
\input{$(realpath $(builddir))/$2-$3}
endef

# $(call tex-wrapper,spanish-or-english,fig-basename,unit-code) -> write to a file
define fig-wrapper
\documentclass[$1]{figure}
\InputIfFileExists{$(subject_code)-macros.tex}{}{}
\InputIfFileExists{unit-$3-macros.tex}{}{}
\begin{document}
\input{$(realpath $(builddir))/$2}
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
.PRECIOUS: $(builddir)/pres-%-es.tex
$(builddir)/pres-%-es.tex: $(builddir)/unit-%-es.tex | $(figdir)
	$(file > $@, $(call tex-wrapper,Presentation,unit-$*,es))

.PRECIOUS: $(builddir)/hdout-%-es.tex
$(builddir)/hdout-%-es.tex: $(builddir)/unit-%-es.tex | $(figdir)
	$(file > $@, $(call tex-wrapper,Handout,unit-$*,es))

.PRECIOUS: $(builddir)/pres-%-en.tex
$(builddir)/pres-%-en.tex: $(builddir)/unit-%-en.tex | $(figdir)
	$(file > $@, $(call tex-wrapper,Presentation,unit-$*,en))

.PRECIOUS: $(builddir)/hdout-%-en.tex
$(builddir)/hdout-%-en.tex: $(builddir)/unit-%-en.tex | $(figdir)
	$(file > $@, $(call tex-wrapper,Handout,unit-$*,en))

## latex to pdf
$(outdir)/%.pdf: $(builddir)/%.tex | $(outdir)
	$(TEXI2DVI) --output=$@ $<

# pdf dependencies
$(depsdir)/%.pdf.d: $(builddir)/%.tex | $(outdir) $(depsdir)
	$(MAKETEXDEPS) -o $@ -t $(outdir)/$*.pdf $<

# figure wrappers
.PRECIOUS: $(builddir)/fig-%-en.tex
$(builddir)/fig-%-en.tex: $(builddir)/fig-%.tex
	$(file > $@, $(call fig-wrapper,English,fig-$*,$(shell echo $* | sed 's/\([^-]*\)-.*/\1/')))

.PRECIOUS: $(builddir)/fig-%-es.tex
$(builddir)/fig-%-es.tex: $(builddir)/fig-%.tex
	$(file > $@, $(call fig-wrapper,Spanish,fig-$*,$(shell echo $* | sed 's/\([^-]*\)-.*/\1/')))

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
