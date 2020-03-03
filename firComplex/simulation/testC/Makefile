CFLAGS+=-g -W -Wall
LDFLAGS=
EXEC_NAME=computeFir
OBJS=main.o fir.o

all: $(EXEC_NAME)

$(EXEC_NAME): $(OBJS)
	$(CC) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $<

clean:
	rm -rf $(OBJS)
	rm -f $(EXEC_NAME)
	rm -f *.c~ *.h~ Makefile~
	rm -f res*.dat
	rm -f test*.txt
	rm -f dump*.txt

.PHONY: clean


