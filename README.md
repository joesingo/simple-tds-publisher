# ukcp-publisher

This repo contains bash scripts to create THREDDS catalogs and NcML
aggregations using the [tds-utils](https://github.com/cedadev/tds-utils)
library, and make them available in THREDDS.

It should be used in conjunction with this ansible playbook:
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

Constants defining where to store catalogs, THREDDS root directory etc are
sourced from a shell script at `/var/lib/tomcat/content/thredds/set_thredds_dirs.sh`.
This file is created by the ansible playbook.

# Usage

There are 3 commands: `./publish.sh add`, `./publish.sh rm` and `./publish.sh ls`.
Usage is as follows:

## add

```
Usage: publish.sh add [-h] -f FILE_LIST -n DATASET_NAME
Create a THREDDS catalog and NcML aggregation from files in FILE_LIST,
re-create the root catalog, and reinit THREDDS.

Options:
  -f FILE_LIST        Read paths to NetCDF files from FILE_LIST. Paths should
                      be separated by newlines. Use - to read from stdin.
  -n DATASET_NAME     Name for the new catalog
  -h                  Show this help and exit
```

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
