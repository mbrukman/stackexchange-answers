#!/usr/bin/python
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
"""Canonicalizes field ordering and values in Jupyter notebooks.

This enables minimal human-reviewable diffs from one version to the next, even
when updated in various tools like Colab, VS Code, etc., each of which make
their own choices in various regards like field ordering, add or update
inconsequential fields and their values, leading to spurious diffs that obscure
the real changes.
"""

import json
import sys
from typing import Dict, List


def processList(data: List):
    """Processes the passed-in list recursively, may modify it in-place."""
    for item in data:
        if isinstance(item, list):
            processList(item)
        elif isinstance(item, dict):
            processDict(item)


def processDict(data: Dict):
    """Processes the passed-in dict recursively, may modify it in-place."""
    # Replace fields with default value `null` which aren't meaningful:
    #
    # * Colab doesn't load a notebook missing the `id` field.
    # * GitHub and `nbconvert` don't load notebooks missing the
    #   `execution_count` field.
    for field in ('execution_count', 'id'):
        if field in data:
            data[field] = None

    # Delete fields which don't need to be present in the notebook.
    for field in ('base_uri', 'hash', 'outputId'):
        if field in data:
            del data[field]

    for key in data.keys():
        if isinstance(data[key], list):
            processList(data[key])
        elif isinstance(data[key], dict):
            if key == 'kernelspec' and 'language' in data[key]:
                del data[key]['language']
            elif key == 'language_info' and 'version' in data[key]:
                del data[key]['version']

            processDict(data[key])

    # Delete list and dict values if empty.
    #
    # GitHub and `nbconvert` require the following fields even if empty:
    # `metadata`, `outputs`.
    required_even_if_empty = ['metadata', 'outputs']
    empty_fields_to_delete = []
    for field in data.keys():
        if field in required_even_if_empty:
            continue
        value = data[field]
        if ((isinstance(value, list) and len(value) == 0) or
            (isinstance(value, dict) and len(value.keys()) == 0)):
            empty_fields_to_delete.append(field)

    for field in empty_fields_to_delete:
        del data[field]


# TODO(mbrukman): add flag `-w` to rewrite the file in-place, a la gofmt.
def main(argv):
    """Parses notebook and outputs canonicalized version to stdout."""
    if len(argv) < 2:
        sys.stderr.write(f'Syntax: {argv[0]} [path-to-notebook]\n')
        sys.exit(1)

    notebook = argv[1]
    json_input = None
    with open(notebook, 'r') as json_file:
        json_input = json.loads(json_file.read())

    # Updates the JSON in-place.
    processDict(json_input)

    # Apply a few more canonicalization rules:
    #
    # * avoid newline at the end of file;
    # * `sort_keys` fixes field ordering inside JSON objects;
    # * use 2-space indent.
    sys.stdout.write(json.dumps(json_input, sort_keys=True, indent=2))


if __name__ == '__main__':
    main(sys.argv)
