# simple-tds-publisher

This repo contains bash scripts to create THREDDS catalogs and NcML
aggregations from lists of files using the
[tds-utils](https://github.com/cedadev/tds-utils) library, and make them
available in THREDDS.

It can be used in conjunction with this ansible playbook:
[ukcp18 TDS playbook](https://breezy.badc.rl.ac.uk/jsingleton/tds-playbook/tree/ukcp18)

# Installation

The only dependencies are bash, python3 and the `tds-utils` library. Create a
virtualenv to install `tds-utils` in:

```bash
venv=/path/to/new/venv
pyvenv-3.5 $venv
source ${venv}/bin/activate
pip install git+https://github.com/cedadev/tds-utils.git
```

# Usage

Some environment variables need to be set before calling `./publish.sh`:

| Name            | Description |
| --------------- | ----------- |
| `SERVER_NAME`   | Hostname of the THREDDS server (used to construct the catalog reinit URL) |
| `THREDDS_ROOT`  | THREDDS content directory in Tomcat `content` directory (required to know where to write root catalog) |
| `THREDDS_USER`  | Username of THREDDS admin user (set in `tomcat-users.xml`) |
| `PASSWORD_FILE` | File containing password for THREDDS admin user |
| `CATALOG_DIR`   | Directory in which to store generated THREDDS catalogs |
| `NCML_DIR`      | As above but for NcML aggregations |

If using the ansible playbook these can be set by sourcing
`/var/lib/tomcat/content/thredds/set_thredds_dirs.sh`.

There are 3 commands: `./publish.sh add`, `./publish.sh rm` and `./publish.sh ls`.
Usage is as follows:

## add

```
Usage:
  publish.sh add [-h] -n DATASET_NAME NETCDF_FILE ...
  publish.sh add [-h] -n DATASET_NAME -r FILE

Create a THREDDS catalog and NcML aggregation from files given,
re-create the root catalog, and reinit THREDDS.

Options:
  -r FILE             Read paths to NetCDF files from FILE. Paths should be
                      separated by newlines. Use - to read from stdin.
  -n DATASET_NAME     Name for the new catalog
  -h                  Show this help and exit
```

The first form allows globs to be used -- e.g.
`./publish.sh add -n mydata /some/path/*/18/*.nc`.

## rm

```
Usage: publish.sh rm DATASET_NAME...
Delete dataset(s), re-create the root catalog, and reinit THREDDS.
```

## ls

```
Usage: publish.sh ls
List the names of currently published datasets
```
