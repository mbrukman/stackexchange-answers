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

# Input settings.
# Keep this list up to date with the output from:
# % gcloud compute images list --project google-containers
SOURCE.centos = centos-6-v20140718
SOURCE.container-vm = container-vm-v20140826
SOURCE.coreos-alpha = coreos-alpha-423-0-0-v20140828
SOURCE.coreos-beta = coreos-beta-410-0-0-v20140825
SOURCE.coreos-stable = coreos-stable-367-1-0-v20140724
SOURCE.debian = debian-7-wheezy-v20140814
SOURCE.debian-backports = backports-debian-7-wheezy-v20140814
SOURCE.opensuse = opensuse-13-1-v20140711
SOURCE.rhel = rhel-6-v20140718
SOURCE.suse = sles-11-sp3-v20140826

IMAGE = debian-backports
SOURCE_IMAGE = $(SOURCE.$(IMAGE))

# Runtime settings.
INSTANCE = autoresize

# Output settings.
GS_BUCKET = centos6-packer-images
IMAGE_NAME = $(SOURCE_IMAGE)-autoresize
DISK_SIZE_GB = 50
