#!/usr/bin/python
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
# Demonstration of catching an exception and verifying its fields.
#
################################################################################

import unittest


class MyException(Exception):
    def __init__(self, message):
        self.message = message


def RaiseException(message):
    raise MyException(message)


class ExceptionTest(unittest.TestCase):
    def verifyComplexException(self, exception_class, message, callable, *args):
        with self.assertRaises(exception_class) as cm:
            callable(*args)

        exception = cm.exception
        self.assertEqual(exception.message, message)

    def testRaises(self):
        self.verifyComplexException(MyException, 'asdf', RaiseException, 'asdf')


if __name__ == '__main__':
    unittest.main()
