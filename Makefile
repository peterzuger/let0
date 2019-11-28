TARGET_NAME ?= let0
PARTNO      ?= STM32L476RG

HALDIR    =../let
LIBCDIR   =../libc
LIBCXXDIR =../libcpp

EXCEPTIONS  = 0
RTTI        = 0
THREADING   = 0
VERBOSE    ?=
DEBUG      ?=

HEAP_SIZE    ?= 0x4000
STACK_SIZE   ?= 0x4000

GETATTR      = tools/getattr.py
DEVICES_FILE = devices.json

FAMILY = $(shell $(GETATTR) $(DEVICES_FILE) $(PARTNO) family)
DEVICE = $(shell $(GETATTR) $(DEVICES_FILE) $(PARTNO) device)
CPU = $(shell $(GETATTR) $(DEVICES_FILE) $(PARTNO) core_type)
ifeq ($(shell $(GETATTR) $(DEVICES_FILE) $(PARTNO) has_fpu),1)
FPU = $(shell $(GETATTR) $(DEVICES_FILE) $(PARTNO) fpu_type)
else
FPU = -mfloat-abi=soft
endif

FLASH_SIZE   = $(shell $(GETATTR) $(DEVICES_FILE) $(PARTNO) flash_size)
FLASH_ORIGIN = $(shell $(GETATTR) $(DEVICES_FILE) $(PARTNO) flash_origin)
RAM_SIZE     = $(shell $(GETATTR) $(DEVICES_FILE) $(PARTNO) ram_size)
RAM_ORIGIN   = $(shell $(GETATTR) $(DEVICES_FILE) $(PARTNO) ram_origin)
IRQ_COUNT    = $(shell $(GETATTR) $(DEVICES_FILE) $(PARTNO) irq_count)

ifeq ($(VERBOSE),1)
	Q =
else
	Q = @
endif

ifeq ($(DEBUG),1)
	DBGFLAGS = -g
else
	DBGFLAGS =
endif

CSRC      = $(wildcard src/*.c)
CXXSRC    = $(wildcard src/*.cpp)

DEPS      = $(CSRC:.c=.o)
DEPS     += $(CXXSRC:.cpp=.o)
LDSCRIPT  = arm

LDDEF  = -DFLASH_ORIGIN=$(FLASH_ORIGIN)
LDDEF += -DFLASH_SIZE=$(FLASH_SIZE)
LDDEF += -DRAM_ORIGIN=$(RAM_ORIGIN)
LDDEF += -DRAM_SIZE=$(RAM_SIZE)
LDDEF += -DHEAP_SIZE=$(HEAP_SIZE)
LDDEF += -DSTACK_SIZE=$(STACK_SIZE)
LDDEF += -DIRQ_COUNT=$(IRQ_COUNT)

CC      = $(Q)arm-none-eabi-
AR      = $(CC)ar
AS      = $(CC)as
CPP     = $(CC)cpp
GCC     = $(CC)gcc
GXX     = $(CC)g++
LD      = $(CC)ld
SIZE    = $(CC)size
OBJCOPY = $(CC)objcopy
OBJDUMP = $(CC)objdump
ECHO    = @echo -e

ifeq ($(VERBOSE),1)
	RM   = rm -v
	MAKE = make
else
	RM   = @rm
	MAKE = $(Q)make -s
endif


FPUFLAGS  = $(FPU)
OPTFLAGS  = -O2 -ffunction-sections -fdata-sections $(DBGFLAGS)
IFLAGS    = -I$(HALDIR)/include -I$(LIBCDIR)/include -I$(LIBCXXDIR)/include
IFLAGS   += -Iinclude
WFLAGS    = -Wall -Wextra -Wpedantic -Wduplicated-cond -Wduplicated-branches
WFLAGS   += -Wlogical-op -Wnull-dereference -Wshadow -Wswitch-default
WFLAGS   += -Wdouble-promotion -Winit-self -Wswitch-enum
WFLAGS   += -Wunsafe-loop-optimizations -Wundef -Wconversion -Winline
WFLAGS   += -Waddress
CWFLAGS   = -Wjump-misses-init

COMFLAGS   = -nostdlib -static -nostartfiles -nostdinc
CCOMFLAGS  = $(IFLAGS) $(COMFLAGS) $(OPTFLAGS) $(FPUFLAGS) -D$(FAMILY) -D$(DEVICE) $(WFLAGS)
CCOMFLAGS += -DIRQ_COUNT=$(IRQ_COUNT) -mthumb -mcpu=$(CPU) -c
GCCFLAGS   = $(CCOMFLAGS)
CXXFLAGS   = $(CCOMFLAGS) -std=c++17
LDFLAGS    = -T $(LDSCRIPT).ld $(DEPS) $(COMFLAGS) $(LIBS) --gc-sections


ifeq ($(EXCEPTIONS), 1)
	CXXFLAGS +=
else
	CXXFLAGS += -fno-exceptions
endif

ifeq ($(RTTI), 1)
	CXXFLAGS +=
else
	CXXFLAGS += -fno-rtti
endif

ifeq ($(THREADING), 1)
	CXXFLAGS +=
else
	CXXFLAGS += -fno-threadsafe-statics
endif

ifeq ($(VERBOSE),1)
	LDFLAGS += --print-gc-sections
endif

all: $(TARGET_NAME).elf

%.o: %.c
	$(ECHO) "GCC\t$@"
	$(GCC) $(GCCFLAGS) $< -o $@

%.o: %.cpp
	$(ECHO) "G++\t$@"
	$(GXX) $(CXXFLAGS) $< -o $@

%.ld: %.lds
	$(ECHO) "CPP\t$@"
	$(CPP) -x c $(LDDEF) $< | grep -v '^#' >$@

$(TARGET_NAME).elf: $(DEPS) $(LDSCRIPT).ld
	$(ECHO) "LD\t$@"
	$(LD) $(LDFLAGS) -o $@

%.bin: %.elf
	$(ECHO) "OBJCOPY\t$@"
	$(OBJCOPY) -O binary $< $@

%.hex: %.elf
	$(ECHO) "OBJCOPY\t$@"
	$(OBJCOPY) -O ihex $< $@

.PHONY: elfdump bindump size
elfdump: $(TARGET_NAME).elf
	$(OBJDUMP) -D $^ | less

bindump: $(TARGET_NAME).bin
	$(OBJDUMP) -b binary -D -marm $^ | less

size: $(TARGET_NAME).bin
	$(SIZE) --target=binary $^


.PHONY: clean install
clean:
	$(RM) -f $(DEPS) *.bin *.elf *.hex
	$(RM) -f $(LDSCRIPT).ld

install: $(TARGET_NAME).bin
	st-flash write $^ $(FLASH_ORIGIN)
