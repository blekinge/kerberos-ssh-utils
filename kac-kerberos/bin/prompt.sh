#!/usr/bin/env bash

# disable the default virtualenv prompt change, as we use our own
export VIRTUAL_ENV_DISABLE_PROMPT=1



#Uses curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
#and sourcing fron .bashrc
#This prints the time before the execution
PS0="\t "

#This prints the command being executed
preexec_functions=()
__preexec_print_command() { echo "'$@'"; }
preexec_functions+=(__preexec_print_command)



RESET="\[\017\]"
NORMAL="\[\033[0m\]"
RED="\[\033[31;1m\]"
YELLOW="\[\033[33;1m\]"
WHITE="\[\033[37;1m\]"
GREEN="\[\033[01;32m\]"
BLUE="\[\033[01;34m\]"




__previous_command_num=0

__prompt_command(){
    EXIT="$?"             # This needs to be first

	__timestamp() {
	    echo -n "\t "
	}

	__kerberos() {
	    #Kerberos ticket user
	    if command -v klist > /dev/null 2>&1; then
	        local kerberos="$( (klist 2>/dev/null || echo '') | grep -oP 'principal: \K\w+')"
	        if [ -n "${kerberos}" ]; then
	            echo -n "(krb:$kerberos) "
	        fi
	    fi
	}

	__virtualenv(){
	    #Include the virtualenv in the prompt
	    if [ -n "$VIRTUAL_ENV" ]; then
	        echo -n "(venv:${VIRTUAL_ENV##*/}) "
	    fi
	}

	__condaEnv(){
	    if [ -n "$CONDA_DEFAULT_ENV" ] && [ "$CONDA_DEFAULT_ENV" != "base" ]; then
	        echo -n "(conda:$CONDA_DEFAULT_ENV) "
	    fi
	}

	__path(){
	    #User, host, workingDir
	    echo -ne "$GREEN\u@\h$NORMAL:$BLUE\w$NORMAL\$ "
	}

	__term_title(){
	    #Gnome terminal title
	    titleString="\u@\h:\w"
	    echo -ne "\033]0;${titleString@P}\007"
	}


    PS1=""
	local var='\#' && local __last_command_num=${var@P}
	if (( __last_command_num <= __previous_command_num )); then
	    #No new command, ignore this
	    EXIT=0
	    PS1+="   "
	else
	    #New command, handle it
	    export __previous_command_num=${__last_command_num}
	    #Smiley for exit of last command
	    if (( EXIT == 0 )); then
	        PS1+="${YELLOW}:)${NORMAL} "
	    else
	        PS1+="${RED}:(${NORMAL} "
	    fi
	fi

	PS1+=$(__timestamp)
	PS1+=$(__kerberos)
	PS1+=$(__virtualenv)
	PS1+=$(__condaEnv)
	PS1+=$(__path)

	__term_title
}
PROMPT_COMMAND=__prompt_command
#source ~/.bash-preexec.sh

