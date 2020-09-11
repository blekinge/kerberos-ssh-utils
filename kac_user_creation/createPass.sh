#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(readlink -f -- ${BASH_SOURCE[0]})")


PASSWORD=$($SCRIPT_DIR/../kac-kerberos/bin/passPhraseGen.sh \
	-j '' \
	-c \
	-l 1 \
	-f "$SCRIPT_DIR/../kac-kerberos/bin/wordlists/dansk-ordliste-unum.txt" \
	-m 25)

echo "$PASSWORD"