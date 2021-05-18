EXEC_NAME=test_fft
SRC= $(wildcard *.c)
OBJS= $(SRC:.c=.o)
HEADERS=fft.h
LDFLAGS=-lm -g -Wall
CFLAGS=$(LDFLAGS)

all:$(EXEC_NAME)

$(EXEC_NAME):$(OBJS)
	$(CC) -o $@ $^ $(LDFLAGS)

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -o $@ -c $<

clean:
	rm -rf $(OBJS)
	rm -f $(EXEC_NAME)
	rm -f *.c~ *.h~ Makefile~
	rm -f *.txt *.dat
