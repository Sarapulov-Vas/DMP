obj-m += dmp.o

ifeq ($(QEMU_BUILD),1)
    PROJECT_ROOT ?= ..
    KDIR := $(PROJECT_ROOT)/build/linux-6.14
else
    KDIR := /lib/modules/$(shell uname -r)/build
endif

PWD := $(shell pwd)

all:
	make -C $(KDIR) M=$(PWD) modules

clean:
	make -C $(KDIR) M=$(PWD) clean
