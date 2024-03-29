#!/usr/bin/env bash
set -e


SCRIPT_DIR=$(dirname "$(readlink -f -- ${BASH_SOURCE[0]})")

cp -r -f -p -- "$SCRIPT_DIR/bin/"* "$HOME/bin/"

set -x

grep -q "source $HOME/bin/java_home.sh" "$HOME/.bash_aliases" || (echo "source $HOME/bin/java_home.sh" >> ~/.bash_aliases)
grep -q "source $HOME/bin/prompt.sh" "$HOME/.bash_aliases" || (echo "source $HOME/bin/prompt.sh" >> ~/.bash_aliases)
grep -q "source $HOME/bin/login_kac" "$HOME/.bash_aliases" || (echo "source $HOME/bin/login_kac" >> ~/.bash_aliases)
grep -q "source $HOME/bin/sshwd.sh" "$HOME/.bash_aliases" || (echo "source $HOME/bin/sshwd.sh" >> ~/.bash_aliases)

# Pull down bash-preexec file from GitHub and write it to our home directory as a hidden file.
wget -N "https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh" --directory-prefix "~/"
# Source our file at the end of our bash profile (e.g. ~/.bashrc, ~/.profile, or ~/.bash_profile)

bashrc_insert='[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh'
grep -v "^\s*$" ~/.bashrc | tail -2| head -2 | grep -q -F "$bashrc_insert" || echo -e "$bashrc_insert" >> ~/.bashrc

diff -w "$SCRIPT_DIR/etc/krb5.conf" "/etc/krb5.conf" | grep  "^<" && \
    echo "You must manually merge $SCRIPT_DIR/etc/krb5.conf and /etc/krb5.conf"

diff -w "$SCRIPT_DIR/ssh/ssh_config" "$HOME/.ssh/config" | grep  '^<' && \
    echo "You must manually merge $SCRIPT_DIR/ssh/ssh_config and $HOME/.ssh/config"


if [[ -e "/usr/share/applications/brave-browser.desktop" && ! -e ~/.local/share/applications/brave-browser.desktop ]]; then
    echo "Installing local brave browser desktop file"
    cp -a /usr/share/applications/brave-browser.desktop ~/.local/share/applications/brave-browser.desktop
fi

#Update google chrome desktop links
function fixChromiumBasedBrowser(){
  echo ""

  domains='\*\.kach\.sblokalnet,\*\.kac\.sblokalnet,\*\.yak2\.net,\*\.kb\.dk,\*\.kbhpc\.kb\.dk'
  #domains='\*'
  insert="--auth-server-whitelist=$domains --auth-negotiate-delegate-whitelist=$domains"

  find "$HOME/.local" 2>/dev/null | grep "$1" | grep "\.desktop" | xargs -r -I'{}' sed -E -i "s|(--auth-server-whitelist=\\S*)||g" "{}"
  find "$HOME/.local" 2>/dev/null | grep "$1" | grep "\.desktop" | xargs -r -I'{}' sed -E -i "s|(--auth-negotiate-delegate-whitelist=\\S*)||g" "{}"
  find "$HOME/.local" 2>/dev/null | grep "$1" | grep "\.desktop" | xargs -r -I'{}' sed -i "/$insert/!s|\(Exec=.*brave-browser.*\)|\1 $insert|g" "{}"

  find "$HOME/.local" 2>/dev/null | grep "$1" | grep "\.desktop" | xargs -r -I'{}' sed -i '/^Exec=/ s/\s\+/ /g' "{}"

  echo "$1"
  find "$HOME/.local" 2>/dev/null | grep "$1" | grep "\.desktop" | xargs -r -I'{}' grep "Exec" "{}"
}

fixChromiumBasedBrowser brave-browser
fixChromiumBasedBrowser google-chrome
