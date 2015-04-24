#!/bin/bash

#set -o errexit # Exit on error
#echo 'Removing cache files'
#rm -R .tmCache

echo 'Creating instrumented node files'
echo '    for CoffeeScript'
coffeeCoverage --path relative ./src ./.coverage/src
coffeeCoverage --path relative ./test ./.coverage/test

echo 'Running Tests locally with (html-file-cov)'
mocha -R html-file-cov ./.coverage  --recursive

echo 'Removing instrumented node files'
rm -f -R .coverage

mv coverage.html .tmCache/coverage.html

echo 'Opening browser with coverage.html'

open .tmCache/coverage.html
