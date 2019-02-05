#!/usr/bin/env bash

set -e

yarn build

cd dist

git init
git add -A
git commit -m 'deploy'

git push -f https://github.com/sin-tanaka/markdown-editor-with-textint.git master:gh-pages

cd -