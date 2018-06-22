#!/bin/bash

### INFOS ###
# v7.2 
### END INFOS ###

# prevent from execution
function __do_not_execute () {

	if  [ "${BASH_SOURCE[0]}" == "${0}" ]; then
		echo "ERROR : This file is not supposed to be executed !"
		exit 1
	fi
}

#shopt -s expand_aliases 

# export colors, font and cursor vars
function __export_tputs_vars () {
	#text colors
	export col_black="$(tput setaf 0)"
	export col_red="$(tput setaf 1)"
	export col_green="$(tput setaf 2)"
	export col_orange="$(tput setaf 3)"
	export col_blue="$(tput setaf 4)"
	export col_purple="$(tput setaf 5)"
	export col_cyan="$(tput setaf 6)"
	export col_white="$(tput setaf 7)"

	#background colors
	export col_bg_black="$(tput setab 0)"
	export col_bg_red="$(tput setab 1)"
	export col_bg_green="$(tput setab 2)"
	export col_bg_orange="$(tput setab 3)"
	export col_bg_blue="$(tput setab 4)"
	export col_bg_purple="$(tput setab 5)"
	export col_bg_cyan="$(tput setab 6)"
	export col_bg_white="$(tput setab 7)"
	export col_reset="$(tput setab 9)"

	#font
	export font_blink="$(tput blink)"
	export font_invis="$(tput invis)"
	export font_bold="$(tput bold)"
	export font_underline="$(tput smul)"
	export font_end_underline="$(tput rmul)"

	#cursor control
	export cur_save="$(tput sc)"
	export cur_restore="$(tput rc)"
	export cur_home="$(tput home)"		# move cursor to upper left corner (0,0)
	export cur_up="$(tput cuu1)" 		# move cursor one line up
	export cur_down="$(tput cud1)" 		# move cursor one line down
	export cur_invis="$(tput civis)"	# set cursor invisible
	export cur_reset="$(tput cnorm)"	# set cursor ton initial test
	#cup <row> <col> set cursor to a specific position

	#reset	
	export col_font_reset="$(tput sgr0)"
}

# return script folder
function __get_execution_path () {
	dirname $(readlink -m "$0")
}

#internal function to print a section from file
function __print_section () {
	local pattern=$1
	local script="$(__get_execution_path $0)/$(basename $0)"
	local pattern_start="###[[:space:]]*$pattern[[:space:]]*###"
	local pattern_stop="###[[:space:]]*END[[:space:]]*$pattern[[:space:]]*###"
	while read line ; do
		eval echo $line
	done < <(sed -n "/$pattern_start/,/$pattern_stop/{//!s/^[[:space:]]*#//p}" $script)
	
}

# print usage, defined at the beginning of the script file between ### USAGE ### and ### END USAGE ###
function __usage () {
	__print_section "USAGE"
}

# clear STDIN to avoid read issues
function _clear_stdin () {
	while read -e -t 0.1; do : ; done
}

function __log () {
	local log_levels="EMERG ALERT CRIT ERR WARN NOTICE INFO DEBUG"
	# Define local to have all log uniformized
	local LANG=en_us_8859_1 
	# args management
	local args=$(getopt -o :f:s:m:l:ei --long logfile:,script:,loglevel:,message:,stderr,stdin -n "$0" -- "$@")
	if [ $? != 0 ] ; then echo "Issue while getting arguments" >&2 ; exit 1 ; fi
	# setting arguments
	eval set -- "$args"
	local logfile=$LOG_FILE script= log_level="INFO" message= stdin= stderr=
	while true; do
		case "$1" in
			-f | --logfile ) logfile=${2}; shift 2 ;;
			-i | --stdin) stdin="enabled"; shift ;;
			-s | --script ) script=$2; shift 2 ;;
			-l | --loglevel ) log_level=$2; shift 2 ;;
			-m | --message ) message=$2; shift 2 ;;
			-e | --stderr ) stderr="enabled"; shift ;;
			-- ) shift; break ;;
			* ) break ;;
		esac
	done
	# find log filename
	if [ -z "$logfile" ]; then logfile="${0}.log";  fi
	# log_level
	if ! grep -q "\<$log_level\>" <<< $log_levels ; then echo "issue : loglevel incorrect value, correct are $log_levels" >&2; exit 1; fi
	local prefix="$(hostname) $(basename $0)[$$]"
	# append log_level if used
	if [ -n "$log_level" ]; then prefix="$prefix $log_level:"; fi
	# treat log only if env var log_level is < log_level
	local current_log_level=${log_level:-INFO}
	if ! echo "${log_levels%$current_log_level*} ${current_log_level}" | grep -q $log_level; then return 0; fi

	# treat stdin
	if [ -n "$stdin" ]; then
		prefix=$(sed 's/\(\[\|\]\|\.\)/\\&/g' <<< $prefix)
		while read line; do
			if [ -z "$stderr" ]; then
				sed "s/^/$(date '+%b %d %X') ${prefix} $message /" <<< $line | tee -a $logfile
			else
				sed "s/^/$(date '+%b %d %X') ${prefix} $message /" <<< $line | tee -a $logfile >&2
			fi
		done
	else
		if [ -z "$stderr" ]; then
			echo "$(date '+%b %d %X') ${prefix} $message" | tee -a $logfile
		else
			echo "$(date '+%b %d %X') ${prefix} $message" | tee -a $logfile >&2
		fi
	fi
}

function __read_log () {
### TODO
	local log_levels="EMERG ALERT CRIT ERR WARN NOTICE INFO DEBUG"
	# args management
	local args=$(getopt -o :f:l:p: --long logfile:,loglevel:,pattern: -n "$0" -- "$@")
	if [ $? != 0 ] ; then echo "issue while getting arguments" >&2 ; exit 1 ; fi
	# setting arguments
	eval set -- "$args"
	local logfile= script= log_level="info" message= stdin= stderr=
	while true; do
		case "$1" in
			-f | --logfile ) logfile=${2:-$logfile}; shift 2 ;;
			-l | --loglevel ) log_level=$2; shift 2 ;;
			-p | --pattern ) log_level=$2; shift 2 ;;
			-- ) shift; break ;;
			* ) break ;;
		esac
	done
	# find log filename
	if [ -z "$logfile" ]; then logfile="${0}.log";  fi
	# log_level
	if ! grep -q "$log_level" <<< $log_levels ; then echo "issue : loglevel incorrect value, correct are $log_levels" >&2; fi
	# treat log only if env var log_level is < log_level
	local current_log_level=${log_level:-info}
	if ! echo "${log_levels%$current_log_level*} ${current_log_level}" | grep -q $log_level; then return 0; fi

	cat $logfile

}



# Add ssh key connection only
# Add bash args management 
# Add ERR trap management
# Add execution lock simultaneous (with wait or not)
# Add is_running pid / prog name
# Add wait_prog pid / prog name
# TODO BASH_COMPAT 
# TODO : add help function on function described in function
# Add multiple associative arrays

### MAIN ###
__do_not_execute

trap control C and run stopWithError
trap stopWithError INT
shopt -s expand_aliases #enable aliases expansion in non interactive shells, otherwise alias aren't found

function killChildren() {
	pid=$$
	processGid=$(ps -q $pid -o pgid | tail -n1)
	pidFile="/dev/shm/pidFile.tmp"
	pgrep -g $processGid >$pidFile
	childrenPidList=$(grep -v $processGid $pidFile| tr "\n" " ")
	[ -n "$childrenPidList" ] && kill -9 $childrenPidList
}

function replaceVarsInFile() {
	templateFileFullPath=$1
	infileReplacement=$2
	returnStatus=0
	if [ "$infileReplacement" != "infile" ]; then
		tmpFile=/dev/shm/replaceVarsInFile.tmp
		cp $templateFileFullPath $tmpFile
		templateFileFullPath=$tmpFile
	fi

	if [ ! -e "$templateFileFullPath" ] ; then
		echo "The template '$templateFileFullPath' could not be found" >&2
		return 1
	fi

	while read aVar 
	do
		##FIXME: check vars exclusion (it coul be removed by improving context control)
		varName=$(echo "$aVar" | sed 's/\(^__\|__$\)//g')
		if [ -z "${!varName}" ] && [ -z "$(echo ${ignoredVariablesInContext[@]} | grep "$varName")" ] ; then
			echo "$varName is not set in file $(basename ${templateFileFullPath}), cannot deploy overcloud" >&2
			 ((returnStatus ++))
		else
			replace=$(echo "${!varName}" | sed "$ !s/$/\\\/ ; s/|/\\\|/g")
			sed -i "s|__${varName}__|${replace}|g" $templateFileFullPath
				
		fi

	done < <( grep -Po '__.*?__' $templateFileFullPath)

	if [ "$infileReplacement" != "infile" ]; then
		cat $tmpFile
		rm $tmpFile
	fi
	return $returnStatus
}
function executeSsh () {
	catchError	
	ssh -i /home/${directorUser}/.ssh/id_rsa -o StrictHostKeyChecking=no  -o  ConnectTimeout=1 -o PasswordAuthentication=no ${@} 2>/dev/null

}

function logScreenOutput () {
	exec 6<&0
	exec 7<&1
	exec 8<&2
	exec 1> >(tee -a "$logFile")
	exec 2> >(tee -a "$logFile" >&2)
	echo ''  &>/dev/null #bugfix: the script hangs up when this line is not executed
}
function restoreFDs () {
	exec 0<&6
	exec 1<&7
	exec 2<&8
}
