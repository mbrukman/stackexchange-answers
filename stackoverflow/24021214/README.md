Overview
========

The code in this directory is intended to answer
[this question](https://stackoverflow.com/q/24021214).

The script `fdisk.sh` automates repartitioning, reboot, and file system resizing
to enable using arbitrarily-sized disks with VM images that by default expand to
only 10GB of space when instantiated.

The script `gcutil.sh` automates VM instance creation, running commands across
all instances, and bringing them all down. It uses the `gcutil` command which is
part of the [Google Cloud SDK](https://developers.google.com/cloud/sdk/) so be
sure to have it installed prior to using these scripts.

Usage
-----

Before trying out any of the examples below, be sure to modify `settings.sh` to
point to a project that you have access to, and which is enabled to create new
GCE VM instances.

To bring up several instances on GCE, run:

```bash
make INSTANCE_SIZES="10 15 30" create
```

After you wait for them to boot, repartition, reboot, and resize the
filesystems, you can verify their new sizes by running `df` on all of them via:

```bash
make INSTANCE_SIZES="10 15 30" df
```

and to bring them all down, run:

```bash
make INSTANCE_SIZES="10 15 30" delete
```

You can override the `IMAGE_OS` variable to choose either `centos` or `debian`
images to be used for the VMs.

Testing
-------

Run the unit tests via:

```bash
make test
```
