CFLAGS+=-g -W -Wall
LDFLAGS=-lm
EXEC_NAME=gen_rom
OBJS=main.o

all: $(EXEC_NAME)

$(EXEC_NAME): $(OBJS)
	$(CC) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $<

clean:
	rm -rf $(OBJS)
	rm -f $(EXEC_NAME)
	rm -f *.c~ *.h~ Makefile~

.PHONY: clean


