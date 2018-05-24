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
    echo "${NCML_DIR}/${1}.ncml"
}

get_catalog_paths() {
    find "$CATALOG_DIR" -type f -name "*.xml"
}

reinit() {
    password=`cat "$PASSWORD_FILE"`
    url="https://${THREDDS_USER}:${password}@${SERVER_NAME}/thredds/admin/debug?catalogs/reinit"
    status=`curl --insecure -o /dev/null -w "%{http_code}" "$url" 2>/dev/null` || \
        die "failed to load catalog reinit URL"
    if [[ $status != 200 ]]; then
        die "failed to reload catalogs -- got HTTP status $status"
    fi
}

create_root_cat() {
    get_catalog_paths | create_catalog root -c - > "$ROOT_CATALOG" -r "$THREDDS_ROOT" || \
        die "failed to create root catalog"
}

#-----------------------------------------------------------------------------#
# Check required env variables are set
[[ -n "$SERVER_NAME" ]]   || die "SERVER_NAME not set"
[[ -n "$THREDDS_ROOT" ]]  || die "THREDDS_ROOT not set"
[[ -n "$THREDDS_USER" ]]  || die "THREDDS_USER not set"
[[ -n "$PASSWORD_FILE" ]] || die "PASSWORD_FILE not set"
[[ -n "$CATALOG_DIR" ]]   || die "CATALOG_DIR not set"
[[ -n "$NCML_DIR" ]]      || die "NCML_DIR not set"

# Set constants
THREDDS_BASE_URL="https://${SERVER_NAME}/thredds"
ROOT_CATALOG="${THREDDS_ROOT}/catalog.xml"
