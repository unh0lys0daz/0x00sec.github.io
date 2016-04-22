#!/bin/bash

git pull
jekyll build
git add -A
git commit -m "Updated build"
git push
