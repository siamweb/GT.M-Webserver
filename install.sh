#!/bin/bash

if [ "$1" = "" ]; then 
    echo "define path to gtm"
else
    export gtmdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    export gtm_dist=$1
    export gtmgbldir="$gtmdir/g/server.gld"
    export gtmroutines="$gtmdir/o*($gtmdir/r) $gtm_dist/libgtmutil.so $gtm_dist"

    export gtm_log="/tmp"
    export gtm_tmp="/tmp"

    #if [ -f $gtmdir/vars ]; then
    #    rm $gtmdir/vars  

    echo '#!/bin/bash' > $gtmdir/vars

    echo "export gtm_max_sockets=1024" >> $gtmdir/vars
    echo "export gtm_dist=$gtm_dist" >> $gtmdir/vars
    echo "export gtmgbldir=$gtmgbldir" >> $gtmdir/vars
    echo "export gtmroutines='$gtmroutines'" >> $gtmdir/vars

    echo "export gtm_log=$gtm_log" >> $gtmdir/vars
    echo "export gtm_tmp=$gtm_tmp" >> $gtmdir/vars

    $gtm_dist/mumps -r GDE @$gtmdir/gde
    cd $gtmdir
    $gtm_dist/mupip create
    $gtm_dist/mupip set -global_buffers=1048576 -file server.dat
fi
