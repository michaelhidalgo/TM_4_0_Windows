#!/bin/bash

#set -o errexit # Exit on error
echo 'Removing cache files'
rm -R .tmCache

if [ ! -f ./node_modules/html-file-cov/package.json ]; then
  echo 'Installing coverage dependencies'
  npm install coffee-coverage
  npm install html-file-cov
fi

echo 'Creating instrumented node files'
coffeeCoverage --path relative ./src ./.coverage/src
coffeeCoverage --path relative ./test ./.coverage/test

echo 'Running Tests locally with (html-file-cov)'
mocha -R html-file-cov ./.coverage/test  --recursive

echo 'Removing instrumented node files'
#rm -R .coverage

mv coverage.html .tmCache/coverage.html

echo 'Opening browser with coverage.html'

open .tmCache/coverage.html