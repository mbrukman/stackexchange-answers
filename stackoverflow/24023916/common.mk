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

include $(LEVEL)/settings.mk

TEMPLATE_YAML = vm.yaml
TEMPLATE_JSON = $(TEMPLATE_YAML:.yaml=.json)

YAML2JSON = $(LEVEL)/yaml2json.py

VERB = @
ifneq ($(VERBOSE),)
  VERB :=
endif

ONLY_FLAG =
ifneq ($(ONLY),)
  ONLY_FLAG = -only=$(ONLY)
  INSTANCE_SUFFIX = -$(ONLY)
endif

EXCEPT_FLAG =
ifneq ($(EXCEPT),)
  EXCEPT_FLAG = -except=$(EXCEPT)
endif

PACKER_VARS = \
  -var bucket_name="$(GS_BUCKET)" \
  -var disk_size_gb="$(DISK_SIZE_GB)" \
  -var image_name="$(IMAGE_NAME)" \
  -var instance_name="$(INSTANCE)$(INSTANCE_SUFFIX)-packer" \
  -var project="$(PROJECT)" \
  -var source_image="$(SOURCE_IMAGE)" \
  -var zone="$(ZONE)"

VM_ENV_VARS = \
  DISK_SIZE_GB="$(DISK_SIZE_GB)" \
  IMAGE_NAME="$(IMAGE_NAME)" \
  INSTANCE="$(INSTANCE)$(INSTANCE_SUFFIX)-test" \
  MACHINE_TYPE="$(MACHINE_TYPE)" \
  PROJECT="$(PROJECT)" \
  ZONE="$(ZONE)"

default:
	$(VERB) echo "Valid actions:"
	$(VERB) echo "  [packer] build, inspect, validate, clean-{local,cloud}"
	$(VERB) echo "  [vm]     vm-{create,df,delete}"
	$(VERB) echo "  [vm]     vm-ssh-{inline,new-window}"

%.json: %.yaml $(YAML2JSON)
	$(VERB) $(YAML2JSON) "$<" > "$@"

build: $(TEMPLATE_JSON)
	$(VERB) packer build -force $(PACKER_VARS) \
	  $(ONLY_FLAG) $(EXCEPT_FLAG) "$<"

inspect: $(TEMPLATE_JSON)
	$(VERB) packer inspect "$<"

validate: $(TEMPLATE_JSON)
	$(VERB) packer validate $(PACKER_VARS) "$<"

clean-local:
	$(VERB) rm -f $(TEMPLATE_JSON)

clean-cloud:
	$(VERB) echo "Removing image: '$(IMAGE_NAME)' ..."
	$(VERB) gcutil --project="$(PROJECT)" deleteimage -f "$(IMAGE_NAME)"
	$(VERB) gsutil rm -f "gs://$(GS_BUCKET)/$(IMAGE_NAME).tar.gz"
	$(VERB) echo "Done."

vm-create:
	$(VERB) env $(VM_ENV_VARS) $(LEVEL)/vm.sh create

vm-df:
	$(VERB) env $(VM_ENV_VARS) $(LEVEL)/vm.sh df

vm-ssh-inline:
	$(VERB) env $(VM_ENV_VARS) $(LEVEL)/vm.sh ssh-inline

vm-ssh-new-window:
	$(VERB) env $(VM_ENV_VARS) $(LEVEL)/vm.sh ssh-new-window

vm-delete:
	$(VERB) env $(VM_ENV_VARS) $(LEVEL)/vm.sh delete
