#!/usr/bin/make -f
# Makefile for hylia #
# ------------------ #
# Created by falkTX
#

AR  ?= ar
CC  ?= gcc
CXX ?= g++

# ----------------------------------------------------------------------------------------------------------------------------
# Fallback to Linux if no other OS defined

ifneq ($(MACOS),true)
ifneq ($(WIN32),true)
LINUX=true
endif
endif

# ----------------------------------------------------------------------------------------------------------------------------
# Set build and link flags

BASE_FLAGS = -Wall -Wextra -pipe -MD -MP
BASE_OPTS  = -O3 -ffast-math -mtune=generic -msse -msse2 -mfpmath=sse -fdata-sections -ffunction-sections

ifeq ($(NOOPT),true)
# No optimization flags
BASE_OPTS  = -O2 -ffast-math -fdata-sections -ffunction-sections
endif

ifneq ($(WIN32),true)
# Not needed for Windows
BASE_FLAGS += -fPIC -DPIC
endif

ifeq ($(DEBUG),true)
BASE_FLAGS += -DDEBUG -O0 -g
ifeq ($(WIN32),true)
BASE_FLAGS += -msse -msse2
endif
else
BASE_FLAGS += -DNDEBUG $(BASE_OPTS) -fvisibility=hidden
CXXFLAGS   += -fvisibility-inlines-hidden
endif

BUILD_C_FLAGS   = $(BASE_FLAGS) -std=gnu99 $(CFLAGS)
BUILD_CXX_FLAGS = $(BASE_FLAGS) -std=gnu++0x $(CXXFLAGS) $(CPPFLAGS)

# ----------------------------------------------------------------------------------------------------------------------------

BUILD_CXX_FLAGS += -Wno-multichar -Wno-unused-variable -Wno-uninitialized -Wno-missing-field-initializers
BUILD_CXX_FLAGS += -Ilink

ifeq ($(LINUX),true)
BUILD_CXX_FLAGS += -DLINK_PLATFORM_LINUX=1
endif

ifeq ($(MACOS),true)
BUILD_CXX_FLAGS += -DLINK_PLATFORM_MACOSX=1
endif

ifeq ($(WIN32),true)
BUILD_CXX_FLAGS += -DLINK_PLATFORM_WINDOWS=1
endif

# ----------------------------------------------------------------------------------------------------------------------------

OBJS = build/hylia.cpp.o
VERSION = 0.0.1

PREFIX = /usr/local
INCDIR = $(PREFIX)/include
LIBDIR = $(PREFIX)/lib

# ----------------------------------------------------------------------------------------------------------------------------

all: build/hylia.a build/hylia.pc

# ----------------------------------------------------------------------------------------------------------------------------

clean:
	rm -rf build

debug:
	$(MAKE) DEBUG=true

# ----------------------------------------------------------------------------------------------------------------------------

install: all
	install -d $(DESTDIR)$(INCDIR)
	install -d $(DESTDIR)$(LIBDIR)/pkgconfig

	install -m 644 hylia.h $(DESTDIR)$(INCDIR)
	install -m 644 build/hylia.a $(DESTDIR)$(LIBDIR)
	install -m 644 build/hylia.pc $(DESTDIR)$(LIBDIR)/pkgconfig

uninstall:
	rm -f $(DESTDIR)$(INCDIR)/hylia.h
	rm -f $(DESTDIR)$(LIBDIR)/hylia.a
	rm -f $(DESTDIR)$(LIBDIR)/pkgconfig/hylia.pc

# ----------------------------------------------------------------------------------------------------------------------------

build/hylia.a: $(OBJS)
	@echo "Creating hylia.a"
	@rm -f $@
	@$(AR) crs $@ $^

build/%.cpp.o: %.cpp
	-@mkdir -p build
	$(CXX) $< $(BUILD_CXX_FLAGS) -c -o $@

build/%.pc: %.pc.in
	sed \
	-e "s|@PREFIX@|$(PREFIX)|" \
	-e "s|@INCDIR@|$(INCDIR)|" \
	-e "s|@LIBDIR@|$(LIBDIR)|" \
	-e "s|@VERSION@|$(VERSION)|" \
	hylia.pc.in > $@

-include $(OBJS:%.o=%.d)

# ----------------------------------------------------------------------------------------------------------------------------
