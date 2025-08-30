KDIR         := ../../linux
EXTRA_CFLAGS :=
obj-m         = test.o

# Cross-compilation pentru x86_64 (poate fi override din command line)
ARCH          ?= x86_64
CROSS_COMPILE ?= x86_64-linux-gnu-

# NOTE: use `shell pwd` instead of `PWD` in case you `make -C ...`
build:
	$(MAKE) -C $(KDIR) M=$(shell pwd) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) modules

clean:
	$(MAKE) -C $(KDIR) M=$(shell pwd) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean

# Target pentru ARM64 nativ (dacă vrei)
build-arm64:
	$(MAKE) -C $(KDIR) M=$(shell pwd) ARCH=arm64 modules

clean-arm64:
	$(MAKE) -C $(KDIR) M=$(shell pwd) ARCH=arm64 clean

# Default target
all: build

.PHONY: build clean build-arm64 clean-arm64 all
