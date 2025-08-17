# Linux kernel development template

A basic setup for learning kernel development.

## Repo structure

 - **linux/:** Kernel as a submodule. Bump version as you see fit.
 - **modules/:** Each subdirectory should be a different project.
 - **rootfs/:** Bootstrapped root filesystem (see next section).
 - **run.sh:** Simple script that starts the test VM.

## Initial (one-time) setup

### Create a root filesystem

```bash
[user@host template]$ mkdir rootfs/

# first installs debian; second is for Arch users
[user@host template]$ sudo debootstrap stable rootfs
[user@host template]$ sudo pacstrap -K rootfs

# set a custom root password
# TIP: consider using arch-chroot from arch-install-scripts
[user@host template]$ sudo chroot rootsfs /bin/bash
[root@chroot /]$ passwd
    New password: root
[root@chroot /]$ exit
```

### Compile the Linux kernel

```bash
[user@host template]$ git submodule update --init linux
[user@host    linux]$ cd linux/

# change x86_64_defconfig -> defconfig if you're on arm64
[user@host linux]$ make x86_64_defconfig kvm_guest.config

# compile kernel and install modules in rootfs
[user@host linux]$ make -j $(nproc)
[user@host linux]$ sudo INSTALL_MOD_PATH=../rootfs/usr make modules_install

# generate compile_commands.json for your language server
# recommended if you're going to work on kernel source
[user@host linux]$ ./scripts/clang-tools/gen_compile_commands.py
```

## Module development

The makefile from the `test/` subdirectory contains more or less all that you
need. A few notes on the variables in this makefile:
 - `KDIR` indicates that **make** should use the recently compiled kernel's
   build system for generating the module. If you want to compile a module for
   your own host (instead of trying it in the VM), override this variable by
   providing it as a CLI argument to **make**:
   `KDIR=/usr/lib/modules/$(uname -r)/build`.
 - `EXTRA_CFLAGS` these extra **gcc** flags will be used only for the
   compilation of this module's sources. For example, you could use
   `-finstrument-functions` to implement some profiling support for your
   module.
 - `obj-m` defines the name of the output kernel object. To skip the confusing
   Kbuild parts: you have a **test.c** so `obj-m` must be set to **test.o** and
   the output kernel module will be **test.ko**. If you want to compile
   multiple sources into a kernel module, check for examples online. Otherwise,
   stick with this.

That's about it. To compile the kernel module:

```bash
[user@host template]$ make -C modules/test
```

If you need language server support, either copy the `compile_commands.json`
that you've generated after compiling the kernel in `linux/` or use [bear][bear]
when compiling the module. Note that the second method will increase the
compilation time by quite a bit.

## Testing

In order to safely test your kernel module, start a VM using the `run.sh` helper
script. There's not much to it, but let's look at each argument for the
`qemu-system` command:
 - **enable-kvm:** Since we're not emulating the guest architecture, this
                   enables kernel acceleration of privileged instruction
                   execution (among other things).
 - **smp:** Number of virtual CPUs.
 - **m:** Amount of RAM assigned to the VM.
 - **nographic:** Instead of opening a terminal in a GUI window, we'll use the
                  current terminal window for I/O. If you want to force quit the
                  VM, press `<Ctrl + A>` and then `X`.
 - **kernel:** Path to the kernel image that we've compiled.
 - **virtfs:** This particular line tells QEMU to take the `rootfs/` directory
               from the host machine and expose it as a Plan 9 filesystem to
               the VM.
 - **append:** The command line arguments for the kernel.

If you run the script and boot the VM, you will see that we can interact with
the VM's root filesystem from our host, during the VM's runtime. Moreover, we
can do tricks like creating bind mounts between a directory accessible to the
VM from within its rootfs, to a directory located on the host's system:

```bash
[user@host template]$ sudo mkdir rootfs/root/test
[user@host template]$ sudo mount --bind modules/test rootfs/root/test
```

After running this on the host, you can check inside the VM that you now have
access to the `modules/test/` directory where you've compiled your module. Try
Inserting the module and then removing it from the kernel:

```bash
[root@vm    ~]$ cd ~/test/
[root@vm test]$ insmod test.ko
[root@vm test]$ rmmod  test.ko

# check the kernel log
[root@vm test]$ dmesg
[  442.437556] test: loading kernel module
[  447.076117] test: unloading kernel module
```

That `test:` string that is prepended to each kernel log message is a result of
our `#define pr_fmt(fmt)` from the source file. Just a little trick to help you
keep track of what your module is doing.

In any case, now you can keep modifying the kernel module's source and recompile
it on your host system. The changes will instantly become visible to the VM,
allowing you to test without restarting the VM on each new build.

## Next steps

Now that you're all set, take a look at the [embetronicx linux device driver
tutorials][embetronicx]. These are still mostly up to date and serve as a good
introduction to the basic kernel APIs and mechanisms.

## TODO
 - [ ] add aarch64 support in run.sh
 - [ ] VM's kernel debugging instructions with gdb


[bear]: https://github.com/rizsotto/Bear
[embetronicx]: https://embetronicx.com/linux-device-driver-tutorials/
