#!/bin/bash
SCRIPT_DIR=$(cd $(dirname $0); pwd)

rails app:template LOCATION=${SCRIPT_DIR}/create-user.rb
