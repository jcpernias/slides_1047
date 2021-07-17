# -*- mode: makefile; -*-

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

units := \
	Intro \
	Size \
	Market-Failure \
	Cost-Benefit

unit_figs :=

LANGUAGES := es
DOC_TYPES := hdout pres


docs_suffixes := $(addprefix _$(subject_code)-, $(LANGUAGES))
docs_prefixes := $(addprefix pres-,$(units)) hdout-all
docs_base := $(foreach suffix,$(docs_suffixes),$(addsuffix $(suffix),$(docs_prefixes)))
docs_pdf := $(addprefix $(outdir)/, $(addsuffix .pdf, $(docs_base)))

## Automatic dependencies
## ================================================================================
docs_deps := $(addprefix $(depsdir)/, $(addsuffix .pdf.d, $(docs_base)))

tex_deps_base := $(foreach suffix,$(docs_suffixes),\
	$(addsuffix $(suffix),$(units) all))

tex_deps := $(addprefix $(depsdir)/unit-, $(addsuffix .tex.d, $(tex_deps_base)))

unit_figs_deps := $(addprefix $(depsdir)/unit-,\
	$(addsuffix _$(subject_code)-figs.d, $(unit_figs)))

all_deps := $(docs_deps) $(tex_deps) $(unit_figs_deps)
