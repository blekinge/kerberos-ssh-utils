#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f $BASH_SOURCE[0]))

cp $SCRIPT_DIR/bin/* ~/bin/

grep -q "source ~/bin/login_kac" ~/.bash_aliases || (echo "source ~/bin/login_kac" >> ~/.bash_aliases)

diff -w $SCRIPT_DIR/etc/krb5.conf /etc/krb5.conf || \
    echo "You must manually merge $SCRIPT_DIR/etc/krb5.conf and /etc/krb5.conf"

diff $SCRIPT_DIR/ssh/config ~/.ssh/config | grep  '^<' && \
    echo "You must manually merge $SCRIPT_DIR/ssh/config and ~/.ssh/config"