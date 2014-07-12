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
# A simple way to test the functionality in the gcutil.sh script by bringing up
# and automatically repartitioning an instance with each of the supported OS
# images.
#
################################################################################

declare -i -r RHEL_SIZE=17
declare -i -r CENTOS_SIZE=19
declare -i -r DEBIAN_SIZE=23
declare -i -r DEBIAN_BACKPORTS_SIZE=24
declare -i -r SUSE_SIZE=25

declare -r COMMAND="$1"

declare -A OS_TO_SIZE=(
  [centos]=15
  [container-vm]=17
  [debian]=19
  [debian-backports]=20
  [rhel]=23
  [suse]=25
)

function run_action() {
  local action="$1"

  rm -f "*.${action}.log"
  local pids=""
  for os in "${!OS_TO_SIZE[@]}"; do
    make INSTANCE_SIZES="${OS_TO_SIZE[$os]}" IMAGE_OS="$os" "${action}" \
      > "${os}.${action}.log" 2>&1 &
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
