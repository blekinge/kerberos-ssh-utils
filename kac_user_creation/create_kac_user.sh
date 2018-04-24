#!/usr/bin/env bash

set -x

USAGE="create_kac_user.sh PROJECT FIRSTNAME LASTNAME USERNAME EMAIL PHONE"

#Validate params
PROJECT="$1"
[ -n "${PROJECT}" ] || >&2 echo "$USAGE" &&  exit 1
FIRSTNAME="$2"
[ -n "${FIRSTNAME}" ] || >&2 echo "$USAGE" &&  exit 1
LASTNAME="$3"
[ -n "${LASTNAME}" ] || >&2 echo "$USAGE" &&  exit 1
USERNAME="$4"
[ -n "${USERNAME}" ] || >&2 echo "$USAGE" &&  exit 1
EMAIL="$5"
[ -n "${EMAIL}" ] || >&2 echo "$USAGE" &&  exit 1
PHONE="$6"
[ -n "${PHONE}" ] || >&2 echo "$USAGE" &&  exit 1


#Validate this host
hostname | grep kac-adm-001 || >&2 echo 'must be executed on host kac-adm-001' && exit 1

#Get the group from the project name
group=$(getent group $PROJECT | cut -d':' -f3)

#Find next available UID
uid=$((group+1))
while id $uid &>/dev/null; do uid=$((uid+1)); done

#Create the user
ipa user-add ${USERNAME} \
    --first="$FIRSTNAME" \
    --last="$LASTNAME" \
    --homedir=/home/${USERNAME} \
    --phone="$PHONE" \
    --uid=$uid \
    --shell=/bin/bash \
    --gidnumber=$uid \
    --class=KacUser \
    --email="$EMAIL"
#Join the relevant groups
ipa group-add-member $PROJECT --user ${USERNAME}
ipa group-add-member kacusers --user ${USERNAME}
ipa group-add-member vpnu --user ${USERNAME}

#Make user home dir
sudo mkdir -p /data/home/${USERNAME}
sudo cp -u /etc/skel/.bash* /data/home/${USERNAME}/
sudo sss_cache -E
sudo chown "${USERNAME}:${USERNAME}" /data/home/${USERNAME} -R

#Set initial password
INITIAL_PASSWORD=$(openssl rand -base64 12)
echo -e "${INITIAL_PASSWORD}\n${INITIAL_PASSWORD}\n" | ipa user-mod ${USERNAME} --password

#Change password so the user can log in
PASSWORD=$(openssl rand -base64 12)
echo -e "${INITIAL_PASSWORD}\n${PASSWORD}\n${PASSWORD}\n" | kinit ${USERNAME} -c /tmp/null
echo ${USERNAME}: ${PASSWORD}
