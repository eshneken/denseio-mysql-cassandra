# OCI DenseIO for MySQL and Cassandra

Scripts to bootstrap and setup an OCI DenseIO 32 OCPU VM with 27.2 TB of DASD with RAID and with MySQL and Cassandra

This should be run with Oracle Linux 7.9.  OL8 ships with Podman, Docker in OL 7.9 is preferred and has been tested here.

* bootstraph.sh - Git clones this repo onto a host.  Helps to pull down all the files onto every host and can potentially be embeded in cloud-init
* setup.sh - Sets up the core database server.  Requires a DB password to be set and adjustments for the Cassandra workloads for ring leader IPs
* client-setup-commands.sh - Sets up the database client.  Some manual intervention is required (passwords, IPs, etc)
* test-optimizations.sh - A set of commands that should be run against clients and servers to maximize performance by doing things like disabling optional Linux and OCI services, removing spectre/meltdown optimizations that may impact performance, moving the docker home to local storage (only do this on a server with local storage), and making sysctl customizations.  This script requires manual intervention.
* disable_services.sh - Script executed by test-optimizations.sh
* sysctl.txt - Kernel customizations
