#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(dirname $(readlink -f $BASH_SOURCE[0]))

hosts="${1:-$SCRIPT_DIR/kac-hosts}"

user="${2:-root}"

newKey="${3:-$HOME/.ssh/id_rsa4096.pub}"

oldKey="$4"

cat "$hosts" | grep -v '^\s*#' | grep -v '^\s*$' |  xargs -r -i -t ssh-copy-id -i "$newKey" $user@{}


if [ -e "$oldKey" ]; then

    echo "Removing key '$oldKey' from hosts"
    echo ""

    oldKeyValue=$(cat "$oldKey.pub")

    set +e
    cat "$hosts" | grep -v '^\s*#' | grep -v '^\s*$' |  \
        xargs -r -i bash -c "ssh -q -o 'IdentitiesOnly=yes' -o 'BatchMode=yes' -i '$oldKey' $user@{} \"sed -i 's|$oldKeyValue||g' '.ssh/authorized_keys'\" && echo 'Removed key on {}' || echo 'Key already removed on {}'"

fi