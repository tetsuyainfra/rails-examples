#!/bin/bash

set -ex

rails db:drop
rails db:create
rails db:migrate
rails db:fixtures:load

rails test
rails server