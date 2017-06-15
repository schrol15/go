#!/usr/bin/env bash

set -e
echo "" > coverage.txt
echo "" > coverage.xml

go version

if [[ $TRAVIS_GO_VERSION == 1.4.3 ]]; then
  go get golang.org/x/tools/cmd/cover
fi

go test -coverprofile=unit_tests.out -covermode=atomic -coverpkg=./messaging ./messaging/

# go test -v -coverprofile=errors_tests.out -covermode=atomic -coverpkg=./messaging \
# ./messaging/tests/ -test.run TestError*

go test -v -coverprofile=integration_tests.out -covermode=atomic -coverpkg=./messaging \
./messaging/tests/ -test.run '^(Test[^(?:Error)].*)'

gocovmerge unit_tests.out integration_tests.out > coverage.txt

ruby parse_coverage.rb > coverage.json

if [ $TRAVIS = true ]; then
  curl -X POST -d @codacy.json "https://api.codacy.com/2.0/coverage/${TRAVIS_COMMIT}/go" --header "project_token: ${CODACY_PROJECT_TOKEN}" --header "Content-Type: application/json; charset=utf-8"
fi

rm unit_tests.out integration_tests.out
