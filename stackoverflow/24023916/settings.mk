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
# Project settings for a Google Cloud Platform project.
# This file should be included into a Makefile.
#
################################################################################

# Google Cloud Project settings.
PROJECT = enthusiastic-lemming-439
ZONE = us-central1-a
MACHINE_TYPE = n1-standard-1

include $(LEVEL)/images.mk

IMAGE = debian-7-backports
SOURCE_IMAGE = $(SOURCE.$(IMAGE))

# Runtime settings.
INSTANCE = autoresize

# Output settings.
GS_BUCKET = centos6-packer-images
IMAGE_NAME = $(SOURCE_IMAGE)-autoresize
DISK_SIZE_GB = 50
