#!/bin/sh
set -e

gem build cfndsl-pipeline.gemspec

gem uninstall -x -a cfndsl-pipeline

gem install $( ls -1rt *.gem | tail -n 1)

