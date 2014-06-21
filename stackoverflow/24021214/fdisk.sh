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

# The ratio between the entire disk and the first partition in blocks or space
# that needs to be exceeded for us to repartition the disk or resize the
# filesystem.
#
# We are giving it some slack in case not all blocks or sectors are in use, and
# we would like to avoid both an infinite loop with reboot, or running resize2fs
# on every reboot.
declare -r THRESHOLD="1.1"

# Args:
#   $1: numerator
#   $2: denominator
#   $3: threshold (optional; defaults to $THRESHOLD)
#
# Returns:
#   1 if (numerator / denominator > threshold)
#   0 otherwise
function ratio_over_threshold() {
  local numer="${1}"
  local denom="${2}"
  local threshold="${3:-${THRESHOLD}}"

  if `which python > /dev/null 2>&1`; then
    python -c "print(1 if (1. * ${numer} / ${denom} > ${threshold}) else 0)"
  elif `which bc > /dev/null 2>&1`; then
    echo "${numer} / ${denom} > ${threshold}" | bc -l
  else
    echo "Neither python nor bc were found; calculation infeasible." >&2
    exit 1
  fi
}

# Repartitions the disk or resizes the file system, depending on the current
# state of the partition table.
function main() {
  # This gets us the size, in blocks, of the whole disk and the first partition.
  declare -i -r DEV_SDA="$(fdisk -s /dev/sda)"
  declare -i -r DEV_SDA1="$(fdisk -s /dev/sda1)"

  # If the ratio between the entire disk and the first partition is over
  # ${THRESHOLD}, then we haven't yet repartitioned the disk. Technically, the
  # ratio between the two of them will be exactly 50 in the case where we're
  # requesting a 500GB disk because OS images on GCE are 10GB.
  #
  # fdisk(1) commands
  # c: disable DOS compatibility mode (must do for CentOS, according to docs)
  # u: change display mode to sectors
  # d: delete partition (automatically selects the first one)
  # n: new partition
  # p: primary
  # 1: partition number
  # <2 blank lines>: accept the defaults for start and end sectors
  # w: write partition table
  if [ $(ratio_over_threshold "${DEV_SDA}" "${DEV_SDA1}") -eq 1 ]; then
    cat <<EOF | fdisk /dev/sda
c
u
d
n
p
1


w
EOF
    # We've made the changes to the partition table, but they just haven't taken
    # effect, so we need to reboot. On the next reboot, the if statement will be
    # false and we'll fall into the else case which will reread the partition
    # table and automatically resize the partition for us.
    reboot
  else
    # After the repartitioning and reboot, we have the following:
    #
    #   fdisk -s /dev/sda  => 524288000
    #   fdisk -s /dev/sda1 => 524286976
    #
    # so the ratio no longer tells us anything. However, now we can examine the
    # actual usable space on disk to see the difference:
    #
    # Before:
    # % df -B 1K | grep /dev/sda1
    # Filesystem           1K-blocks      Used Available Use% Mounted on
    # /dev/sda1             10319160   1020760   8774216  11% /
    # [...]
    #
    # After:
    # % df -B 1K | grep /dev/sda1
    # Filesystem           1K-blocks      Used Available Use% Mounted on
    # /dev/sda1            516060600   1041548 488811080   1% /
    # [...]
    #
    # so we can still use the ratio to see if we need to fix this.
    declare -i -r DEV_SDA1_DF="$(df -B 1K | grep /dev/sda1 | awk '{ print $2 }')"
    if [ $(ratio_over_threshold "${DEV_SDA}" "${DEV_SDA1_DF}") -eq 1 ]; then
      resize2fs /dev/sda1
    fi
  fi
}

# Emulate Python's way of only executing the code if this file were invoked as
# the main one:
#
# if __name__ == '__main__':
#   ...
if [[ "$(basename $0)" != "fdisk_test.sh" ]]; then
  main
fi
