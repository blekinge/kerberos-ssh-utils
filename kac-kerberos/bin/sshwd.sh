function sshwd() {
(   #Subshell to handle exit correctly with the exec statements

	# From https://gist.github.com/stbuehler/4672115
	local sshargs=()

	while (( $# > 0 )); do
		case "$1" in
		-[1246AaCfgKkMNnqsTtVvXxYy])
			# simple argument
			sshargs+=("$1")
			shift
			;;
		-[bcDeFIiLlmOopRSWw])
			# argument with parameter
			sshargs+=("$1")
			shift
			if (( $# == 0 )); then
				echo "missing second part of long argument" >&2
				exit 99
			fi
			sshargs+=("$1")
			shift
			;;
		-[bcDeFIiLlmOopRSWw]*)
			# argument with parameter appended without space
			sshargs+=("$1")
			shift
			;;
		--)
			# end of arguments
			sshargs+=("$1")
			shift
			break
			;;
		-*)
			echo "unrecognized argument: '$1'" >&2
			exit 99
			;;
		*)
			# end of arguments
			break
			;;
		esac
	done

	# user@host
	sshhost=("$1")
	shift

	#Everything that remains in $@ is now the command
	if [ -z "$@" ]; then
		exec ssh -t "${sshargs[@]}" "$sshhost" "cd $PWD; bash"
	else
		exec ssh    "${sshargs[@]}" "$sshhost" "cd $PWD; $@"
	fi

)
}
export sshwd
