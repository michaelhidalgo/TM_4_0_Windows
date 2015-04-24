#!/bin/bash

if [ ! -f ./node_modules/mocha-lcov-reporter/package.json ]; then
  echo 'Installing coverage dependencies'
  npm install coffee-coverage
  npm install mocha-lcov-reporter
  npm install coveralls
fi

#set -o errexit # Exit on error
echo 'Removing cache files'
rm -R .tmCache

echo 'Creating instrumented node files'
echo '    for CoffeeScript'
coffeeCoverage --path relative ./src ./.coverage/src
coffeeCoverage --path relative ./test ./.coverage/test

echo 'Running Tests locally with (html-file-cov)'
mocha -R mocha-lcov-reporter .coverage/test --recursive | sed 's,SF:,SF:src/,;/test/s,src,test,' | ./node_modules/coveralls/bin/coveralls.js

echo 'Removing instrumented node files'
rm -R .coverage