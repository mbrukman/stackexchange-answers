1. Install [Packer](http://packer.io) as described in the
   [README.md](https://github.com/mitchellh/packer/blob/master/README.md).

2. In `settings.mk`, specify:

   * `PROJECT`: Google Cloud Platform project to use for building Packer images
   * `GS_BUCKET`: Google Cloud Storage bucket to use for storing images
   * `IMAGE_NAME`: the name of the image that will be created

   These variables can also be overridden on the `make` command line.

3. Authentication is easiest if you're already running from a VM on Google
   Compute Engine with the proper read-write scopes, as described in the
   [Packerdocumentation](http://www.packer.io/docs/builders/googlecompute.html),
   as there's nothing else you need to do here.

4. Choose whether you want an auto-resizing image or a fixed-size image.
   Auto-resizing is supported by those distributions which have `cloud-init` and
   `cloud-initramfs-growroot` packages, which are recent versions of:

   * backports-debian-7-wheezy (short name: `debian-backports`)
   * container-vm (short name: `container-vm`)

   For these distributions, run the Packer build from the `auto-resize` directory.

   For other distributions, the `fixed-size` directory is a work-in-progress.

5. Build the Packer image:

   ```bash
   $ cd auto-resize
   ```

   and then:

   ```
   $ make IMAGE=container-vm build

   # OR

   $ make IMAGE=debian-backports build
   ```

6. Run the VM with the newly-created image:

   ```bash
   % make vm-create
   ```

7. Wait a while for the VM to boot, and verify the size of the root partition in
   bytes:

   ```bash
   $ make vm-df
   ```

   If you want to log in to the instance for manual inspection, run:

   ```bash
   $ make vm-ssh-inline      # in the same terminal

   # OR

   $ make vm-ssh-new-window  # in a new gnome-terminal window
   ```

8. Once you're done, delete the VM:

   ```bash
   $ make vm-delete
   ```

9. To list all available make targets, run:

   ```bash
   $ make
   ```
