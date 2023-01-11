CC ?= gcc
CFLAGS ?= -O0 -Wall -g 
LDFLAGS = -export-dynamic
PKGCONFIG = $(shell which pkg-config)
GTK_INC = $(shell $(PKGCONFIG) --cflags gtk+-3.0)
GTK_LIB = $(shell $(PKGCONFIG) --libs gtk+-3.0)

SOURCEDIR = src
BUILDDIR = build
IMAGEDIR = data/images
EXECUTABLE = SpaceInvaders

RESOURCES_XML = data/resources.xml
RESOURCES_SOURCE = build/resources.c
RESOURCES_OBJECT = build/resources.o

ASM_SOURCES = $(wildcard $(SOURCEDIR)/*.S) 
C_SOURCES = $(wildcard $(SOURCEDIR)/*.c) 

ASM_OBJECTS = $(patsubst $(SOURCEDIR)/%.S,$(BUILDDIR)/%.o,$(ASM_SOURCES))
C_OBJECTS = $(patsubst $(SOURCEDIR)/%.c,$(BUILDDIR)/%.o,$(C_SOURCES))

OBJECTS = $(ASM_OBJECTS) $(C_OBJECTS) $(RESOURCES_OBJECT)


.phony: all
all: dir $(BUILDDIR)/$(EXECUTABLE)

dir:
	mkdir -p $(BUILDDIR)

$(BUILDDIR)/$(EXECUTABLE): $(OBJECTS)
	$(CC) -o $@ $(LDFLAGS) $^ $(GTK_LIB)

$(RESOURCES_SOURCE):
	glib-compile-resources --target=$(RESOURCES_SOURCE) --generate-source $(RESOURCES_XML)

$(RESOURCES_OBJECT): $(RESOURCES_SOURCE)
	$(CC) -c -o $@ $(CFLAGS) $(GTK_INC) $<

$(C_OBJECTS): $(BUILDDIR)/%.o : $(SOURCEDIR)/%.c
	$(CC) -c -o $@ $(CFLAGS) $(GTK_INC) $<

$(ASM_OBJECTS): $(BUILDDIR)/%.o : $(SOURCEDIR)/%.S
	$(CC) -c -o $@ $(CFLAGS) $<

.phony: clean
clean:
	rm -rf $(BUILDDIR)