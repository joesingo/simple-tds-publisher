#!/bin/bash

usage() {
    cat <<EOF
Usage: $PROG ls [-h]
List the names of currently published datasets

Options:
  -h    Show this help and exit
EOF
}

#-----------------------------------------------------------------------------#

if [[ $1 = "-h" || $1 = "--help" ]]; then
    usage
    exit 0
fi

get_catalog_paths | sed "s,${CATALOG_DIR}/,,; s,\.xml$,,"
