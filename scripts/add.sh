#!/bin/bash

usage() {
    cat <<EOF
Usage:
  $PROG add [-h] -n DATASET_NAME NETCDF_FILE ...
  $PROG add [-h] -n DATASET_NAME -r FILE

Create a THREDDS catalog and NcML aggregation from files given,
re-create the root catalog, and reinit THREDDS.

Options:
  -r FILE             Read paths to NetCDF files from FILE. Paths should be
                      separated by newlines. Use - to read from stdin.
  -n DATASET_NAME     Name for the new catalog
  -h                  Show this help and exit
EOF
}

#-----------------------------------------------------------------------------#

while getopts hr:n: opt; do
    case "$opt" in
        h) usage
           exit 0
           ;;
        r) file_list="$OPTARG"
           ;;
        n) dataset_name="$OPTARG"
           ;;
    esac
done
shift $((OPTIND - 1))

# Check arguments
if [[ -z $dataset_name ]]; then
    usage >&2
    exit 1
elif [[ -z $file_list && -z $@ ]]; then
    warn "Use -r option or list datasets on command line"
    usage >&2
    exit 1
fi

# Write file list to a file if reading from stdin or listing files on command
# line
if [[ -z $file_list || $file_list = "-" ]]; then
    made_temp=yes
    temp_file=`mktemp`

    if [[ $file_list = "-" ]]; then
        cat > "$temp_file"
    else
        echo "$@" | sed 's, ,\n,g' > "$temp_file"
    fi
    file_list="$temp_file"
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
