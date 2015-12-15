#!/bin/bash

git pull
bundle install
JEKYLL_ENV=production jekyll build
