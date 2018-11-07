#!/bin/bash


function run_step () {

	step_name="$1"
	shift
	cmd="${@}"
	echo "####### Running step :  $step_name"
	${@}
	ret=$?
	echo "###### Step ${step_name} finnished with ret code = $ret"
	echo ""
	
	return $ret
}


function run_step_multicmd () {

	
	step_name="$1"
	shift
	cmd="${@}"
	echo "####### Running step :  $step_name"

	while read line; do
		$line
		ret=$?
		if [ "$ret" -ne 0 ]; then
			echo "ERROR on command : $line"
			stop_on_error
		fi

	done
	echo "###### Step ${step_name} finnished with success"
	echo ""
	
	return $ret
}





