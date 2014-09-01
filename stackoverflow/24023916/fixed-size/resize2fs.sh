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

# After the repartitioning and reboot, we have the following:
#
#   fdisk -s /dev/sda  => 524288000
#   fdisk -s /dev/sda1 => 524286976
#
# so the ratio no longer tells us anything. However, now we can examine the
# actual usable space on disk to see the difference:
#
# Before (on CentOS):
# % df -B 1K /dev/sda1
# Filesystem           1K-blocks      Used Available Use% Mounted on
# /dev/sda1             10319160   1020760   8774216  11% /
#
# After (on CentOS):
# % df -B 1K /dev/sda1
# Filesystem           1K-blocks      Used Available Use% Mounted on
# /dev/sda1            516060600   1041548 488811080   1% /
#
# On Debian, the device behind the root filesystem is not /dev/sda1 but a
# disk with random UUID, e.g.,
#
# % df -B 1K /
# Filesystem              1K-blocks   Used Available Use% Mounted on
# /dev/disk/by-uuid/{...}  10320184 680336   9115612   7% /
#
# % df -B 1K /dev/sda1
# Filesystem     1K-blocks  Used Available Use% Mounted on
# udev               10240     0     10240   0% /dev
#
# so we read the size of the root partition to work on both.
function main() {
  local dev_sda="$(fdisk -s /dev/sda)"
  local dev_sda1_df="$(df -B 1K / | grep ' /$' | awk '{ print $2 }')"
  if [ $(ratio_over_threshold "${dev_sda}" "${dev_sda1_df}") -eq 1 ]; then
    resize2fs /dev/sda1
  fi
}

# Emulate Python's way of only executing the code if this file were invoked as
# the main one:
#
# if __name__ == '__main__':
#   ...
if [[ "$(basename $0)" != "resize2fs_test.sh" ]]; then
  main
fi
