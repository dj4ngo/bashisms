#!/bin/bash



function  stop_on_error () {

	cat << EOF 
AAAAHHHHHH !!!
Je ferme tous les fichiers
Je stope les services eventuels
je supprime mes fichiers temporaires
EOF
	exit 1

}
