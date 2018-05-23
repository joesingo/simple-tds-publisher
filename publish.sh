#!/bin/bash

SCRIPTS_DIR="`dirname $0`/scripts"
source "${SCRIPTS_DIR}/common.sh"

usage() {
    cat <<EOF
Usage: $PROG [-h] COMMAND
Manage THREDDS catalogs and NcML aggregations

Commands:
  add    Add a new dataset
  rm     Remove a dataset
  ls     List published datasets
EOF
}

#-----------------------------------------------------------------------------#

if [[ $1 = "-h" || $1 = "--help" ]]; then
    usage
    exit 0
fi

if [[ $1 = "add" || $1 = "rm" || $1 = "ls" ]]; then
    cmd="$1"
    shift
    source "${SCRIPTS_DIR}/${cmd}.sh"
else
    case "$1" in
        -h | --help | "")
            usage
            exit 0
            ;;
        *)
            warn "unrecognised command '$1'"
            usage
            ;;
    esac
fi
