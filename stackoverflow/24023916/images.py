#!/usr/bin/python
#
# Copyright 2015 Google Inc.
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

"""Update VM OS images and short names."""

import argparse
import glob
import json
import sys


def GetImageAliases(vm_images, prefix_to_shortname):
  with open(vm_images, 'r') as json_in:
    project_images = json.load(json_in)
    for project, images in project_images.iteritems():
      if 'pseudo' in images:
        for latest in images['pseudo']:
          has_custom_shortname = False

          for prefix, name in prefix_to_shortname:
            if latest.startswith(prefix):
              has_custom_shortname = True
              shortname = name
              break

          if not has_custom_shortname:
            shortname = latest[:len(latest) - len('-latest')]

          yield (shortname, project, images['pseudo'][latest])


def main(argv):
  parser = argparse.ArgumentParser(
    description=__doc__,
    formatter_class=argparse.RawDescriptionHelpFormatter)

  # This uses the `vm_images.json` from the following project:
  # https://github.com/GoogleCloudPlatform/cloud-launcher/blob/master/src/cache/vm_images.json
  parser.add_argument('--vm_images', dest='vm_images', required=True,
                      help='Pre-processed JSON-formatted VM images data')

  flags = parser.parse_args(argv[1:])

  # We accept some aliases from `vm_images.json` as-is (i.e., by stripping the
  # date suffix); others we rewrite. This lists just the ones which we modify to
  # suit our purposes for brevity.
  prefix_to_shortname = [
      ('debian-7-wheezy-', 'debian-7'),
      ('backports-debian-7-', 'debian-7-backports'),
      ('nvme-backports-debian-7-', 'debian-7-backports-nvme'),
      ('opensuse-13-', 'opensuse-13'),
      ('sles-11-sp3-', 'sles-11'),
      ('ubuntu-1204-precise-', 'ubuntu-1204'),
      ('ubuntu-1404-trusty-', 'ubuntu-1404'),
      ('ubuntu-1410-utopic-', 'ubuntu-1410'),
  ]

  shortname_project_image = GetImageAliases(
      flags.vm_images, prefix_to_shortname)

  for shortname, _, image in sorted(shortname_project_image):
    print 'SOURCE.%s = %s' % (shortname, image)


if __name__ == '__main__':
  main(sys.argv)
