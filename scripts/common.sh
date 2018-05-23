#!/bin/bash

PROG=`basename $0`

#-----------------------------------------------------------------------------#
# Functions

log() {
    echo "$PROG: $@"
}

warn() {
    echo "$PROG: $@" >&2
}

die() {
    warn $@
    exit 1
}

# Usage: get_catalog_path DATASET_NAME
get_catalog_path() {
    echo "${CATALOG_DIR}/${1}.xml"
}

# Usage: get_ncml_path DATASET_NAME
get_ncml_path() {
    echo "${NCML_DIR}/${1}.xml"
}

get_catalog_paths() {
    find "$CATALOG_DIR" -type f -name "*.xml"
}

reinit() {
    password=`cat "$PASSWORD_FILE"`
    url="https://admin:${password}@${SERVER_NAME}/thredds/admin/debug?catalogs/reinit"
    if ! curl --insecure "$url" >/dev/null 2>&1; then
        die "failed to reload catalogs"
    fi
}

create_root_cat() {
    get_catalog_paths | create_catalog root -c - > "$ROOT_CATALOG" -r "$THREDDS_ROOT" || \
        die "failed to create root catalog"
}

#-----------------------------------------------------------------------------#
# Set constants

source "/var/lib/tomcat/content/thredds/set_thredds_dirs.sh"
THREDDS_BASE_URL="https://${SERVER_NAME}/thredds"
ROOT_CATALOG="${THREDDS_ROOT}/catalog.xml"
