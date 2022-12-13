CC ?= gcc
CFLAGS ?= -O0 -Wall -g 
LDFLAGS = -export-dynamic
PKGCONFIG = $(shell which pkg-config)
GTK_INC = $(shell $(PKGCONFIG) --cflags gtk+-3.0)
GTK_LIB = $(shell $(PKGCONFIG) --libs gtk+-3.0)

BINARY = tp_vintagegame
C_SRCS = lib/main.c lib/utils.c
ASM_SRCS = src/process_game1_asm.S 

OBJS = $(ASM_SRCS:.S=.o) $(C_SRCS:.c=.o)

all: $(BINARY)

%.o: %.c
	$(CC) -c -o $@ $(CFLAGS) $(GTK_INC) $<

%.o: %.S
	$(CC) -c -o $@ $(CFLAGS) $<

$(BINARY): $(OBJS) 
	$(CC) -o $@ $(LDFLAGS) $^ $(GTK_LIB)

clean:
	rm -f $(OBJS) $(BINARY)
