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
# A simple way to test the functionality in the gcloud.sh script by bringing up
# and automatically repartitioning an instance with each of the supported OS
# images.
#
################################################################################

declare -r COMMAND="$1"

declare -r IMAGES="
    centos-6
    centos-7
    container-vm
    coreos
    debian-7
    debian-7-backports
    debian-8
    opensuse-13
    rhel-6
    rhel-7
    sles-11
    sles-12
    ubuntu-12-04
    ubuntu-14-04
    ubuntu-14-10
    ubuntu-15-04
"

function run_action() {
  local action="$1"

  rm -f "*.${action}.log"
  local pids=""
  for image in ${IMAGES} ; do
		echo "[${action}] VM instance from image: ${image} ..."
    make INSTANCE_SIZES="19" IMAGE="${image}" "${action}" \
      > "${image}.${action}.log" 2>&1 &
    pids="${pids} $!"
  done
  wait ${pids}
}

case "${COMMAND}" in
  create)
    run_action create
    ;;

  delete)
    run_action delete
    ;;

  df)
    run_action df
    cat *.df.log
    ;;

  clean)
    rm -f *.log
    ;;

  *)
    echo "Valid actions: create, delete, df, clean" >&2
    exit 1
    ;;
esac
