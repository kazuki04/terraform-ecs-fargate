#!/bin/bash
# bundle exec rails s -p 3000 -b '0.0.0.0'
bundle exec puma -C config/puma.rb
