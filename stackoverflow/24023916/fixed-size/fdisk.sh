#!/bin/bash -u
#
# Copyright 2014 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################
#
# We're restoring a 10GB OS image onto a larger disk. That space will not be
# visible until we repartition the disk, which then also requires us to reboot
# the instance.
#
# We assume that there's a single disk at /dev/sda with a single root partition
# and we're extending it to fill the entire disk for simplicity.
#
# See detailed docs here:
# https://developers.google.com/compute/docs/disks#repartitionrootpd
#
################################################################################

# Of interest is that fdisk(1) has opposite behavior on CentOS vs. Debian.
# While the 'c' and 'u' commands can be used to toggle DOS compatibility mode
# and cylinder (vs. sector) display, respectively, it turns out that fdisk(1)
# starts in opposite modes on CentOS (both enabled) vs. Debian (both
# disabled), so unconditionally using those commands has the opposite effect
# on those two distributions.
#
# However, using the -c and -u flags disables them (as we want) on both
# distributions, so we use them as flags instead of commands.
#
# fdisk(8) flags:
# -c: disable DOS compatibility mode
# -u: change display mode to sectors (from cylinders)
#
# fdisk(8) commands:
# d: delete partition (automatically selects the first one)
# n: new partition
# p: primary
# 1: partition number
# <2 blank lines>: accept the defaults for start and end sectors
# w: write partition table
#
# fdisk(8) appears to exit with a non-zero exit code when it changes the
# partition table, so since Packer is very sensitive to it, we need to make sure
# it does not terminate the build process by masking it.
cat <<EOF | fdisk -c -u /dev/sda || true
d
n
p
1


w
EOF
