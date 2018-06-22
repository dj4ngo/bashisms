#!/bin/bash


### USAGE ###
# $0 --help
# $0 -h
# $0 help
### END USAGE ###

# source lib
. general_lib.sh

export LOG_LEVEL=${LOG_LEVEL:-NOTICE}
export LOG_FILE=test.log




__log -m "info" -l INFO
__log -m "notice" -l NOTICE
__log -m "debug" -l DEBUG
__log -m "warning" -l WARN



__log -eim 'pwet' --loglevel WARN <<EOF 
line1
line2
line3
line4
line5
EOF


echo FIN
