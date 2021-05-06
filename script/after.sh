#!/bin/bash
set -ev
if [ "${TRAVIS_RUBY_VERSION}" = "2.5.9" ]; then
  ./cc-test-reporter after-build --exit-code $TRAVIS_TEST_RESULT
fi
