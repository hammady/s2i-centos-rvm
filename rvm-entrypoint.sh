#!/bin/bash

source $STI_SCRIPTS_PATH/common

detect_ruby_version

exec "$@"
