# -*- mode: makefile; -*-

subject_code := 1047
units := \
	01 \
	03 \
	05 \
	06 \
	06 \
	07 \
	08 \
	09 \
	10 \
	11 \
	12 \
	13

unit_figs := \
	03 \
	05 \
	06 \
	07 \
	09 \
	11 \
	12

LANGUAGES := es

docs_suffixes := $(addprefix _$(subject_code)-, $(LANGUAGES))
docs_prefixes := $(addprefix pres-,$(units)) $(addprefix hdout-,$(units)) hdout-all
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
