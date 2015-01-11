#!/bin/bash
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
# Install the package "cloud-init" and the "growroot" tool it includes. Upon
# reboot, it will automatically repartition the root volume to fill all
# available space.
#
################################################################################

echo "Installing growroot ..."
if which apt-get > /dev/null 2>&1 ; then
  # Debian and derivatives.
  echo "Using apt-get (Debian, Ubuntu, etc.) ..."
  apt-get -qq -y update
  apt-get -qq -y install cloud-init cloud-initramfs-growroot
elif which yum > /dev/null 2>&1 ; then
  # RHEL and CentOS.
  echo "Using rpm/yum (RHEL, CentOS, etc.); WARNING: work-in-progress"
  rpm -Uvh --quiet "https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm"
  yum makecache
  yum -q -y install cloud-init cloud-initramfs-tools dracut-modules-growroot
elif which zypper > /dev/null 2>&1 ; then
  # SUSE and derivatives.
  echo "Using zypper (SUSE, etc.); WARNING: work-in-progress"
  zypper refresh
  zypper --non-interactive --quiet install cloud-init cloud-utils
else
  echo "Not a supported OS: none of {apt-get, yum, zypper} were found." >&2
  exit 2
fi
echo "Done"
