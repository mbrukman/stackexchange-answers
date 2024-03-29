#!/bin/bash -eu
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

for file in LICENSE Makefile nbconvert_test.sh nbfmt.py nbfmt_update.sh run_nbfmt_test.sh ; do
  echo "Downloading the latest version of: ${file} ..."
  curl -sO "https://raw.githubusercontent.com/mbrukman/reimplementing-ml-papers/main/${file}"
done

# Ensure all the scripts are executable.
chmod u+x *.py *.sh

echo "Done."
