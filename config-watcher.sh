#!/bin/bash
# docs
# $1: input file
# $2: output file

set -euo pipefail

if [ -z "$1" ]; then
    echo "config-watcher: ERROR: no input file specified"
    exit 1;
fi;

if [ -z "$2" ]; then
    echo "config-watcher: ERROR: no output file specified"
    exit 1;
fi;

INPUT_FILE=$1
OUTPUT_FILE=$2

envsubst < $INPUT_FILE > $OUTPUT_FILE
echo "watching $INPUT_FILE for changes"

onchange() {
    echo "changed $INPUT_FILE"
    envsubst < $INPUT_FILE > $OUTPUT_FILE
    echo "updated $OUTPUT_FILE"
}

while inotifywait -qe close_write $INPUT_FILE; do onchange ; done