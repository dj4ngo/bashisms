#!/bin/bash


function declare_array () {
	shopt -s expand_aliases 
	local array_name="$(mktemp  -p /dev/shm)" 
	jq -n '[]' > $array_name
	alias "$1=__manage_array $array_name"
}


function __manage_array () {
	local array_name="$1" 
	shift
	
	if grep -q "=" <<< ${@}; then 
		echo "set"
	else
		echo "get"
	fi


#jq '. |= (. +  [{"name":"'$name'"}] |unique)' ${scriptDir}/../${zone}/${nodesInfoFilename} > $tmpJsonFile
#                                        mv $tmpJsonFile ${scriptDir}/../${zone}/${nodesInfoFilename}

}


declare_array MyArray
MyArray ["toto1"]["toto2"]="valtoto"
echo $MyArray
