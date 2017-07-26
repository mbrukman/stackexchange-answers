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

# A simple script to create, access (via SSH), and delete GCE instances.

declare -r INSTANCE="${INSTANCE:-vm-resize-test}"

declare -r COMMAND="$1"
case "${COMMAND}" in

  create)
    gcloud compute instances create "${INSTANCE}" \
      --project "${PROJECT}" \
      --zone "${ZONE}" \
      --machine-type "${MACHINE_TYPE}" \
      --image-project "${PROJECT}" \
      --image "${IMAGE_NAME}" \
      --boot-disk-size "${DISK_SIZE_GB:-10}"
    ;;

  delete)
    gcloud compute instances delete "${INSTANCE}" \
      --project "${PROJECT}" \
      --zone "${ZONE}" \
      --quiet
    ;;

  ssh-inline)
    gcloud compute ssh "${INSTANCE}" \
      --project "${PROJECT}" \
      --zone "${ZONE}"
    ;;

  ssh-new-window)
    gnome-terminal -x \
      gcloud compute ssh "${INSTANCE}" \
      --project "${PROJECT}" \
      --zone "${ZONE}" &
    ;;

  df)
    gcloud compute ssh "${INSTANCE}" \
      --project "${PROJECT}" \
      --zone "${ZONE}" \
      --command df | grep ' /$' | awk '{ print $2 }'
    ;;

  *)
    echo "Valid commands: create, delete, ssh-{inline,window}, df" >&2
    exit 1
    ;;

esac
