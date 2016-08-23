#!/bin/bash

export gtmdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $gtmdir/vars

cd $gtmdir
$gtm_dist/mumps -run ^WWW

