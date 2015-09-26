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
# Create a number of instances and automatically repartition them.
#
################################################################################

source "$(dirname $0)/settings.sh" || exit 1

# Returns a fully-qualified URL pointing to the VM image.
#
# Args:
#   $1: project
#   $2: VM image
function vm_image_url() {
  local project="${1}"
  local image="${2}"
  echo "https://www.googleapis.com/compute/v1/projects/${project}/global/images/${image}"
}

# The startup script to run at boot to automatically repartition or grow the
# root partition to fill the available disk space.
declare -r STARTUP_SCRIPT_GROWROOT="growroot.sh"
declare -r STARTUP_SCRIPT_FDISK="fdisk.sh"
STARTUP_SCRIPT="${STARTUP_SCRIPT:-${STARTUP_SCRIPT_FDISK}}"

# Creates an instance name given an instance size.
#
# Args:
#   $1: instance disk size in GB
function instance_name() {
  echo "${IMAGE}-${1}gb"
}

# Creates several instances given their disk sizes. Instance names will be
# computed automatically.
#
# Args:
#   $*: instance disk sizes in GB
function create_instances() {
  local pids=""
  for gb in $*; do
    local instance="$(instance_name ${gb})"
    gcloud \
      --project "${PROJECT}" \
      compute instances create "${instance}" \
      --zone "${ZONE}" \
      --image "${IMAGE}" \
      --machine-type "${MACHINE_TYPE}" \
      --boot-disk-size "${gb}" \
      --metadata-from-file "startup-script=${STARTUP_SCRIPT}" &
    pids="${pids} $!"
  done
  wait ${pids}
}

# Deletes instances corresponding to the given disk sizes. Instance names will
# be computed automatically, and will correspond to the ones created by
# `create_instances()`.
#
# Args:
#   $*: instance disk sizes in GB
function delete_instances() {
  local pids=""
  for gb in $*; do
    local instance="$(instance_name ${gb})"
    gcloud \
      --project="${PROJECT}" \
      compute instances delete \
      --quiet \
      --delete-disks=all \
      --zone="${ZONE}" \
      "${instance}" &
    pids="${pids} $!"
  done
  wait ${pids}
}

# Runs `df` on each instance corresponding to the given disk sizes and shows the
# output. Useful for testing the automatic repartitioning script interactively.
#
# Args:
#   $*: instance disk sizes in GB
function disk_free() {
  for gb in $*; do
    local instance="$(instance_name ${gb})"
    echo "Running df on [${instance}] ..."
    gcloud \
      --project "${PROJECT}" \
      compute ssh \
      --zone "${ZONE}" \
      --ssh-flag="-q" \
      "${instance}" \
      df / | grep ' /$' | awk '{ print $2 }'
  done
}

# Runs an interactive `ssh` session (in serial) on every instance corresponding
# to the list of disk sizes provided. This is only useful for a small number of
# instances.
#
# Alternatively, this can be changed to create several separate terminal
# windows, each running its own `ssh` command.
#
# Args:
#   $*: instance disk sizes in GB
function ssh() {
  for gb in $*; do
    local instance="$(instance_name ${gb})"
    echo "Running ssh on [${instance}] ..."
    gcloud \
      --project "${PROJECT}" \
      compute ssh \
      --zone "${ZONE}" \
      --ssh-flag="-q" \
      "${instance}"
  done
}

declare -r COMMAND="$1"
shift

case "${COMMAND}" in
  create)
    create_instances $*
    ;;

  delete)
    delete_instances $*
    ;;

  df)
    disk_free $*
    ;;

  ssh)
    ssh $*
    ;;

  *)
    echo "Valid commands: create, delete, df, ssh." >&2
    exit 1
esac
