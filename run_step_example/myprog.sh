#!/bin/bash


# Run in debug mode
# set -x

# stop on first error
#set -e


trap  stop_on_error ERR
# source libraries
source libs/all



run_step "install package"  echo "J'installe mes paquets"

run_step "step qui se passe bien" /bin/true
#run_step "step qui se passe mal" /bin/false


run_step_multicmd "step multiligne de test" << EOF
echo "cmd1"
echo "cmd2"
echo "cmd3"
EOF


run_step_multicmd "step multiligne KO de test" << EOF
echo "OK"
echo "KO"
/bin/false
EOF

