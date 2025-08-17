#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt "\n"

#include <linux/kernel.h>
#include <linux/module.h>

static int __init
test_init(void)
{
    pr_info("loading kernel module");

    /* return -1 for module insertion to fail */
    return 0;
}

static void __exit
test_exit(void)
{
    pr_info("unloading kernel module");
}

module_init(test_init);
module_exit(test_exit);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Test kernel module");

