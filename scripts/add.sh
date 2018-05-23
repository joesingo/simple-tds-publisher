#!/bin/bash

usage() {
    cat <<EOF
Usage: $PROG add [-h] -f FILE_LIST -n DATASET_NAME
Create a THREDDS catalog and NcML aggregation from files in FILE_LIST,
re-create the root catalog, and reinit THREDDS.

Options:
  -f FILE_LIST        Read paths to NetCDF files from FILE_LIST. Paths should
                      be separated by newlines. Use - to read from stdin.
  -n DATASET_NAME     Name for the new catalog
  -h                  Show this help and exit
EOF
}

#-----------------------------------------------------------------------------#

while getopts hf:n: opt; do
    case "$opt" in
        h)
            usage
            exit 0
            ;;
        f)
            file_list="$OPTARG"
            ;;
        n)
            dataset_name="$OPTARG"
            ;;
    esac
done

if [[ -z $file_list || -z $dataset_name ]]; then
    usage >&2
    exit 1
fi

# Copy stdin to a temp file if file given is '-'
if [[ $file_list = "-" ]]; then
    made_temp=yes
    file_list=`mktemp`
    cat > "$file_list"
fi

catalog_path=`get_catalog_path "$dataset_name"`
ncml_path=`get_ncml_path "$dataset_name"`

log "creating catalog..."
create_catalog dataset -f "$file_list" -i "$dataset_name" -n "$ncml_path" -o > "$catalog_path" || \
    die "failed to create catalog"

log "aggregating..."
<"$file_list" aggregate -d time >"$ncml_path" || die "failed to create aggregation"

log "regenerating root catalog..."
create_root_cat

log "reloading catalogs..."
reinit

# TODO: Test once OPeNDAP aggregations are working
# log "caching aggregations..."
# json=`mktemp`
# cat > "$json" <<EOF
# {
#     "${dataset_name}": {"generate_aggregation": true}
# }
# EOF
# cache_remote_aggregations -v $json "$THREDDS_BASE_URL"
# rm "$json"

if [[ -n $made_temp ]]; then
    rm "$file_list"
fi
