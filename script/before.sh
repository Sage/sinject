#!/bin/bash
set -ev
if [ "${TRAVIS_RUBY_VERSION}" = "2.5.9" ]; then
  curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > ./cc-test-reporter
  chmod +x ./cc-test-reporter
  ./cc-test-reporter before-build
fi
