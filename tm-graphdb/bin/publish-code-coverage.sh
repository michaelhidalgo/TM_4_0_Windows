#!/bin/bash

#if [ ! -f ./node_modules/mocha-lcov-reporter/package.json ]; then
  echo 'Installing coverage dependencies'
  npm install jscover
  npm install coffee-coverage
  npm install mocha-lcov-reporter
  npm install coveralls
#fi

#set -o errexit # Exit on error
echo 'Removing cache files'
rm -R -f .tmCache

echo 'Creating instrumented node files'
echo '    for CoffeeScript'
coffeeCoverage --path relative ./src ./.coverage/src
coffeeCoverage --path relative ./test ./.coverage/test

echo 'Running with mocha-lcov-reporter and publishing to coveralls'
mocha -R mocha-lcov-reporter .coverage --recursive | sed 's,SF:,SF:src/,;/test/s,src,test,' | ./node_modules/coveralls/bin/coveralls.js

echo 'Removing instrumented node files'
rm -f -R .coverage

echo 'Opening browser with coveralls page for this project'

open https://coveralls.io/r/TeamMentor/TM_4_0_GraphDB
