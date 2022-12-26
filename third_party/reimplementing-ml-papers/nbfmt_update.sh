#!/bin/bash -u
#
# Copyright 2022 Google LLC
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

function clean_file() {
  local file="$1"
  local out="${file}.out"
  local err="${file}.err"

  echo -n "Updating ${file} ... "
  if python "$(dirname $0)/nbfmt.py" "${file}" > "${out}" 2> "${err}"; then
    # No issues; will continue with diffing `${out}` below.
    rm "${err}"
  else
    echo "error:"
    echo
    cat "${err}"
    echo
    rm "${out}" "${err}"
    return
  fi

  if diff "${file}" "${out}" > /dev/null 2>&1; then
    rm "${out}"
    echo "no change."
  else
    mv "${out}" "${file}"
    echo "done."
  fi
}

for file in $(find . -name \*\.ipynb | sort); do
  clean_file "${file}"
done
