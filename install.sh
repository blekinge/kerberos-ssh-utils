#!/usr/bin/env bash
set -x
set -e

SCRIPT_DIR=$(dirname $(readlink -f $BASH_SOURCE[0]))

cp -f -p -- "$SCRIPT_DIR/bin/"* "$HOME/bin/"

grep -q "source $HOME/bin/login_kac" "$HOME/.bash_aliases" || (echo "source $HOME/bin/login_kac" >> ~/.bash_aliases)

diff -w "$SCRIPT_DIR/etc/krb5.conf" "/etc/krb5.conf" || \
    echo "You must manually merge $SCRIPT_DIR/etc/krb5.conf and /etc/krb5.conf"

diff "$SCRIPT_DIR/ssh/ssh_config" "$HOME/.ssh/config" | grep  '^<' && \
    echo "You must manually merge $SCRIPT_DIR/ssh/ssh_config and $HOME/.ssh/config"


#Update google chrome desktop links
insert='--auth-server-whitelist=\*\.kach\.sblokalnet,\*\.kac\.sblokalnet'
find "$HOME/.local" 2>/dev/null | grep "chrome" | grep "\.desktop" | xargs -r -I'{}' sed -i "/'$insert'/!s|\(Exec=.*google-chrome.*\)|\1 '$insert'|g" "{}"