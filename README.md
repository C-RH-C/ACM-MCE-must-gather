# acm_create-must-gather.sh - must-gather automation
    
Script to automate process of creating must-gather for RHACM support,

This script checks ACM and MCE version and create proper must-gathers
for support team. This script is aimed to run on HUB or managed cluster now.

Works with ACM version 2.4, 2.5, 2.6 and 2.7, prepared for ACM 2.8

## Disclaimer:

This scripts are NOT delivered and/or released by Red Hat. This is an independent project to help customers and Red Hat Support team to export and/or collect the data from Red Hat Advanced Cluster Management and managed clusters for reporting or troubleshooting purposes.

## Usage:

Details about usage can be shown be '-h' option:

```
$ acm_create-must-gather.sh -h
```

Common usage is:

```
$ acm_create-must-gather.sh -d OUTPUT_DIR
```

or with specified own registry (for disconnected env):

```
$ acm_create-must-gather.sh -d OUTPUT_DIR -r internal.repo.address:port
```

The `OUTPUT_DIR` must not exists. This dir is created. Output structure:

```
OUTPUT_DIR/
  |-acm/     --- contains data collected by ACM must-gather
  |-mce/     --- data collected by MCE must-gather
  |-acm-must-gather.log  --- output of ACM m-g
  |-mce-must-gather.log  --- output of MCE m-g
```

`OUTPUT_DIR` is archived to `./acm_must_gather-$TIMESTAMP.tar.xz`

## Requirements:

The script is written in BASH and for successful usage needs:
  * **oc** - CLI tool for manage OpenShift clusters - https://console.redhat.com/openshift/downloads
  * **jq** - Tool for parsing JSON. Part of linux distributions, how to install, please check your distribution manual
  * **tar** and few other common linux CLI tools.

The script is tested on Linux distributions.

## Known issues:
  * ~~Not tested on non-HUB cluster for now.~~ - For collecting data from managed cluster, use `-m <ACM version>` option
  * Do not cover situation, when image for m-g is not available, but
    this can be checked from `oc adm must-gather ...` output in specified
    dir (acm-must-gather.log and mce-must-gather.log).


## TODO:
  * when executed on HUB cluster, show message like "This script gather data from HUB cluster now. If your issue with ACM affects some managed cluster, please run this script to gather data from managed cluster too." - done
  * Add functionality to collect data for submariner support
