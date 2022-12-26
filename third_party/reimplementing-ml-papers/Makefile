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

VERB = @
ifeq ($(VERBOSE),1)
	VERB =
endif

SRC_DIR ?= .

.PHONY: test clean

test: nbfmt-test

nbfmt-test:
	$(VERB) echo "Notebook format tests"
	$(VERB) echo
	$(VERB) $(SRC_DIR)/run_nbfmt_test.sh

update: nbfmt-update

nbfmt-update:
	$(VERB) $(SRC_DIR)/nbfmt_update.sh

nbconvert-test:
	$(VERB) echo "Notebook conversion tests"
	$(VERB) echo
	$(VERB) $(SRC_DIR)/nbconvert_test.sh

datasets-test:
	$(VERB) make -C datasets test
