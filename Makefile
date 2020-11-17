CC = $(PREFIX)gcc
CFLAGS = -g -O0
EXTRA_CFLAGS =
EXTRA_LDFLAGS =
LDSCRIPT = pcie.ld
ELF = pcie
STRIP = pcie.strip
HEX = pcie.hex
SREC = pcie.srec
BIN = pcie.bin
STANDALONE = yes

SRCS := $(wildcard *.c)
ifeq ($(strip $(STANDALONE)), yes)
#SRCS += imc_boot.S
endif
TMP := $(patsubst %.c, %.o, $(SRCS))
TMP += $(patsubst %.S, %.o, $(SRCS))
OBJS = $(filter %o, $(TMP))

ifeq ($(strip $(STANDALONE)), yes)
	EXTRA_CFLAGS += -ffreestanding -mcmodel=medany -DSTANDALONE
	EXTRA_LDFLAGS += -nostdlib -T $(LDSCRIPT)
endif

$(HEX): $(BIN) $(SREC)
	./bin2vhx.pl $< $@  --width=64

$(BIN): $(STRIP)
	$(PREFIX)objcopy -O binary $< $@

$(SREC): $(STRIP)
	$(PREFIX)objcopy -O srec $< $@

$(STRIP): $(ELF)
	$(PREFIX)strip -R .comment -R .note $< -o $@

$(ELF) : $(OBJS)
	$(CC) -o $@ $^ $(EXTRA_LDFLAGS)

%.o : %.c
	$(CC) -o $@ -c $< $(CFLAGS) $(EXTRA_CFLAGS)

%.o : %.S
	$(CC) -o $@ -c $< $(CFLAGS) $(EXTRA_CFLAGS)

clean:
	-@rm -fr $(HEX) $(BIN) $(STRIP) $(ELF) $(OBJS)

display:
	@echo SRCS: $(SRCS)
	@echo OBJS: $(OBJS)
	@echo TARGET: $(BIN)
