EXEC_NAME=gen_data
SRC= $(wildcard *.c)
OBJS= $(SRC:.c=.o)
LDFLAGS=-lm -g -Wall

all:$(EXEC_NAME)

$(EXEC_NAME):$(OBJS)
	$(CC) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $<

clean:
	rm -rf $(OBJS)
	rm -f $(EXEC_NAME)
	rm -f *.c~ *.h~ Makefile~
