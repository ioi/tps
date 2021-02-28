#
# Makefile used for compiling C++ programs and running Python programs, caching
# both their executables/outputs and compilation/error outputs.
#
# For each C++ program, its compilation output is written to a file and kept
# together with the executable.
# Naming format:
#	Program:             my_program.cpp
#	Executable:          my_program.exe
#	Compilation output:  ._my_program.cpp.compile.out
# The compilation output is kept so that it can be read later, e.g. to find if
# there were compilation warnings.
#
# For each Python program, its error output is written to a file and kept
# together with the run output.
# Naming format:
#	Program:       my_program.py
#	Run output:    my_program
#	Error output:  ._my_program.py.err.out
# 
# Used Makefile features/concepts are commented through the code.
#

# Defining some recursively expanded variables

CXXFLAGS=-std=gnu++1y -Wall -Wextra -O2

CPP_EXT=cpp
HEADER_EXT=h
EXE_EXT=exe
COMPILE_OUT_PREFIX=._
CPP_COMPILE_OUT_SUFFIX=.$(CPP_EXT).compile.out
CPP_COMPILE_TMP_OUT_SUFFIX=.$(CPP_EXT).compile.tmp.out

PY_EXT=py
ERR_OUT_PREFIX=._
PY_ERR_OUT_SUFFIX=.$(PY_EXT).err.out
PY_ERR_TMP_OUT_SUFFIX=.$(PY_EXT).err.tmp.out

# Forcing 'make' to use 'bash' instead of 'sh'.
# Otherwise, "set -o pipefail" will not work.
SHELL=/bin/bash

# Defining some simply expanded variables
# Using 'wildcard' function to find all C++ sources and headers
CPP_HEADERS := $(wildcard *.$(HEADER_EXT))
CPP_SOURCES := $(wildcard *.$(CPP_EXT))
# Defining variables through substitution references
EXECUTABLES := $(CPP_SOURCES:%.$(CPP_EXT)=%.$(EXE_EXT))
COMPILE_OUTPUTS := $(CPP_SOURCES:%.$(CPP_EXT)=$(COMPILE_OUT_PREFIX)%$(CPP_COMPILE_OUT_SUFFIX))

PY_SOURCES := $(wildcard *.$(PY_EXT))
PY_OUTPUTS := $(PY_SOURCES:%.$(PY_EXT)=%)
ERR_OUTPUTS := $(PY_SOURCES:%.$(PY_EXT)=$(ERR_OUT_PREFIX)%$(PY_ERR_OUT_SUFFIX))

# Defining .PHONY targets
.PHONY: all clean compile_outputs_list

all: $(PY_OUTPUTS) $(ERR_OUTPUTS) $(EXECUTABLES) $(COMPILE_OUTPUTS)

clean:
	ls *.$(PY_EXT) | sed 's/.$(PY_EXT)$$//' | xargs rm -f
	rm -f $(ERR_OUT_PREFIX)*$(PY_ERR_TMP_OUT_SUFFIX) $(ERR_OUT_PREFIX)*$(PY_ERR_OUT_SUFFIX)
	rm -f *.$(EXE_EXT) $(COMPILE_OUT_PREFIX)*$(CPP_COMPILE_TMP_OUT_SUFFIX) $(COMPILE_OUT_PREFIX)*$(CPP_COMPILE_OUT_SUFFIX)

# Suppressing recipe echoing with @
compile_outputs_list:
	@echo $(COMPILE_OUTPUTS)

# Using 'shell' function
coloring_enabled := $(shell if [ -t 2 ] ; then echo true ; else echo false ; fi)
# Using Makefile conditionals
ifeq ($(coloring_enabled),true)
  cpp_coloring_flag=-fdiagnostics-color=always
else
  cpp_coloring_flag=-fdiagnostics-color=never
endif

# Defining pattern rules with more than one target
# Defining pattern-specific variable values
CPP_TARGET_PATTERNS=%.$(EXE_EXT) $(COMPILE_OUT_PREFIX)%$(CPP_COMPILE_OUT_SUFFIX)
$(CPP_TARGET_PATTERNS): COMPILE_TMP_OUTPUT=$(COMPILE_OUT_PREFIX)$*$(CPP_COMPILE_TMP_OUT_SUFFIX)
$(CPP_TARGET_PATTERNS): COMPILE_OUTPUT=$(COMPILE_OUT_PREFIX)$*$(CPP_COMPILE_OUT_SUFFIX)
$(CPP_TARGET_PATTERNS): COMPILE_COMMAND=g++ $(CXXFLAGS) $< -o $*.$(EXE_EXT) $(cpp_coloring_flag)
$(CPP_TARGET_PATTERNS): %.$(CPP_EXT) $(CPP_HEADERS)
	@echo $(COMPILE_COMMAND)
	@set -o pipefail  &&  $(COMPILE_COMMAND) 2>&1  |  tee -i $(COMPILE_TMP_OUTPUT) 1>&2
	@mv $(COMPILE_TMP_OUTPUT) $(COMPILE_OUTPUT)

PY_TARGET_PATTERNS=% $(ERR_OUT_PREFIX)%$(PY_ERR_OUT_SUFFIX)
$(PY_TARGET_PATTERNS): ERR_TMP_OUTPUT=$(ERR_OUT_PREFIX)$*$(PY_ERR_TMP_OUT_SUFFIX)
$(PY_TARGET_PATTERNS): ERR_OUTPUT=$(ERR_OUT_PREFIX)$*$(PY_ERR_OUT_SUFFIX)
$(PY_TARGET_PATTERNS): RUN_COMMAND=python3 $< > $*
$(PY_TARGET_PATTERNS): %.$(PY_EXT) $(PY_HEADERS)
	@echo "$(RUN_COMMAND)"
	@set -o pipefail  &&  $(RUN_COMMAND) 2>&1  |  tee -i $(ERR_TMP_OUTPUT) 1>&2
	@mv $(ERR_TMP_OUTPUT) $(ERR_OUTPUT)
