#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/bio.h>
#include <linux/blk_types.h>
#include <linux/device-mapper.h>

struct my_dm_target {
    struct dm_dev *dev;
    sector_t start;
};

static int basic_target_map(struct dm_target *ti, struct bio *bio)
{
    struct my_dm_target *mdt = ti->private;
    printk(KERN_INFO "\n<<in function basic_target_map\n");

    bio_set_dev(bio, mdt->dev->bdev);

    if (op_is_write(bio_op(bio))) {
        printk(KERN_INFO "\nbasic_target_map: bio is a write request\n");
    } else {
        printk(KERN_INFO "\nbasic_target_map: bio is a read request\n");
    }

    submit_bio(bio);

    printk(KERN_INFO "\n>>out function basic_target_map\n");       
    return DM_MAPIO_SUBMITTED;
}

static int basic_target_ctr(struct dm_target *ti, unsigned int argc, char **argv)
{
    struct my_dm_target *mdt;
    unsigned long long start;
    int ret;

    printk(KERN_INFO "\n>>in function basic_target_ctr\n");

    if (argc != 2) {
        ti->error = "Invalid argument count";
        printk(KERN_ERR "Invalid no.of arguments.\n");
        return -EINVAL;
    }

    mdt = kmalloc(sizeof(struct my_dm_target), GFP_KERNEL);
    if (!mdt) {
        ti->error = "dm-basic_target: Cannot allocate context";
        printk(KERN_ERR "Mdt allocation failed\n");
        return -ENOMEM;
    }

    if (sscanf(argv[1], "%llu", &start) != 1) {
        ti->error = "dm-basic_target: Invalid device sector";
        ret = -EINVAL;
        goto bad;
    }

    mdt->start = (sector_t)start;
    
    ret = dm_get_device(ti, argv[0], dm_table_get_mode(ti->table), &mdt->dev);
    if (ret) {
        ti->error = "dm-basic_target: Device lookup failed";
        goto bad;
    }

    ti->private = mdt;
    printk(KERN_INFO "\n>>out function basic_target_ctr\n");                       
    return 0;

bad:
    kfree(mdt);
    printk(KERN_ERR "\n>>out function basic_target_ctr with error\n");           
    return ret;
}

static void basic_target_dtr(struct dm_target *ti)
{
    struct my_dm_target *mdt = ti->private;
    printk(KERN_INFO "\n<<in function basic_target_dtr\n");        
    dm_put_device(ti, mdt->dev);
    kfree(mdt);
    printk(KERN_INFO "\n>>out function basic_target_dtr\n");               
}

static struct target_type basic_target = {
    .name = "basic_target",
    .version = {1, 0, 0},
    .module = THIS_MODULE,
    .ctr = basic_target_ctr,
    .dtr = basic_target_dtr,
    .map = basic_target_map,
};

static int __init init_basic_target(void)
{
    int result = dm_register_target(&basic_target);
    if (result < 0) {
        printk(KERN_ERR "Error in registering target: %d\n", result);
        return result;
    }
    printk(KERN_INFO "dm-basic_target registered successfully\n");
    return 0;
}

static void __exit cleanup_basic_target(void)
{
    dm_unregister_target(&basic_target);
    printk(KERN_INFO "dm-basic_target unregistered\n");
}

module_init(init_basic_target);
module_exit(cleanup_basic_target);
MODULE_LICENSE("GPL");
