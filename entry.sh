#!/bin/bash

APP_ENV=test bundle exec rspec spec
APP_ENV=dev bundle exec rackup --host 0.0.0.0 -p 3087
