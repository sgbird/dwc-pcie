CC = gcc
SRCS = $(wildcard *.c)
OBJS = $(patsubst %.c, %.o, $(SRCS))
CFLAGS = -g
EXTRA_CFLAGS =
#NAME = $(wildcard *.c)
BIN = pcie

$(BIN) : $(OBJS)
	$(CC) -o $@ $^ $(CFLAGS) $(EXTRA_CFLAGS)

%.o : %.c
	$(CC) -o $@ -c $< $(CFLAGS) $(EXTRA_CFLAGS)

clean:
	-@rm -fr $(TARGET) $(OBJS)

display:
	@echo OBJS: $(OBJS)
