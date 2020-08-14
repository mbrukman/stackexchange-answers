# Overview

The code in this directory supports [this answer][answer] to [the
question][question] about repartitioning boot disks on Google Compute Engine.

The script `fdisk.sh` automates repartitioning, reboot, and file system resizing
to enable using arbitrarily-sized disks with VM images that by default expand to
only 10GB of space when instantiated.

The script `gcloud.sh` automates VM instance creation, running commands across
all instances, and bringing them all down. It uses the `gcloud` command which is
part of the [Google Cloud SDK](https://cloud.google.com/sdk/) so be
sure to have it installed prior to using these scripts.

## Usage

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

You can override the `IMAGE` variable to choose other images to be used for the
VMs.

You can also use the [`gcloud_test.sh`](gcloud_test.sh) script to bring up a
number of VMs, each with a different OS image, check the disk size, and delete
them. See the script for usage details.

[answer]: https://stackoverflow.com/a/24102667/3618671
[question]: https://stackoverflow.com/q/24021214/3618671
