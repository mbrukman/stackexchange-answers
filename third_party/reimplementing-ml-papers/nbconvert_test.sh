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

declare -i status=0

function test_file() {
  local file="$1"
  local html="${file/%ipynb/html}"
  local err="${file}.err"

  jupyter nbconvert --to html "${file}" 2> "${err}"
  if [ $? -eq 0 ]; then
    echo "Converting ${file} ... ok"
  else
    status=1
    echo "::group::Converting ${file} ... failed"
    cat "${err}"
    echo "::endgroup::"
  fi
  rm -f "${err}" "${html}"
}

for file in $(find . -name \*\.ipynb | sort); do
  test_file "${file}"
done

echo
if [ ${status} -eq 0 ]; then
  echo "PASSED"
else
  echo "FAILED"
fi

exit ${status}
