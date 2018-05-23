#!/bin/bash

usage() {
    cat <<EOF
Usage: $PROG rm DATASET_NAME...
Delete dataset(s), re-create the root catalog, and reinit THREDDS.

Options:
  -h    Show this help and exit
EOF
}

#-----------------------------------------------------------------------------#

if [[ $1 = "-h" || $1 = "--help" || -z $1 ]]; then
    usage
    exit 0
fi

for dataset_name in "$@"; do
    log "deleting ${dataset_name}..."
    catalog_path=`get_catalog_path "$dataset_name"`
    rm "$catalog_path" || warn "could not delete catalog"

    ncml_path=`get_ncml_path "$dataset_name"`
    rm "$ncml_path" || warn "could not delete ncml"
done

log "regenerating root catalog..."
create_root_cat

log "reloading catalogs..."
reinit
