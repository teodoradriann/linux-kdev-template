KDIR         := ../../linux
EXTRA_CFLAGS :=
obj-m         = test.o

# NOTE: use `shell pwd` instead of `PWD` in case you `make -C ...`

build:
	$(MAKE) -C $(KDIR) M=$(shell pwd) modules

clean:
	$(MAKE) -C $(KDIR) M=$(shell pwd) clean

