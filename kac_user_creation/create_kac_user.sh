#!/usr/bin/env bash

set -x

USAGE="create_kac_user.sh PROJECT FIRSTNAME LASTNAME USERNAME EMAIL PHONE"

echo "Validating parameters $@"
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


echo "Validating this host $(hostname)"
hostname | grep kac-adm-001 || >&2 echo 'must be executed on host kac-adm-001' && exit 1

echo "Get the group from the project name '$PROJECT'"
group=$(getent group $PROJECT | cut -d':' -f3)
if [ -z "$group" ]; then
    echo "you must create group with 'ipa group-add $PROJECT --gid=<GID>' before using this script"
    exit 1
fi
echo "Found GID for project to be $group"

echo "Checking if $USERNAME already exists"
if ! id ${USERNAME} > /dev/null ; then
    echo "User $USERNAME already exists, aborting"
    exit 1
fi
echo "$USERNAME does not exist"

echo "Find next available UID, starting from GID=$group"
uid=$((group+1))
while id $uid &>/dev/null; do
    uid=$((uid+1));
done
echo "uid=$uid have been chosen for the new user $USERNAME"


echo "Create the user $USERNAME in FreeIPA"
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

echo "$USERNAME joins the relevant groups"
ipa group-add-member $PROJECT --user ${USERNAME}
ipa group-add-member kacusers --user ${USERNAME}
ipa group-add-member vpnu --user ${USERNAME}

echo "Make user home dir /data/home/$USERNAME"
sudo mkdir -p /data/home/${USERNAME}
sudo cp -u /etc/skel/.bash* /data/home/${USERNAME}/
sudo sss_cache -u ${USERNAME}
sudo chown "${USERNAME}:${USERNAME}" /data/home/${USERNAME} -R

INITIAL_PASSWORD=$(openssl rand -base64 12)
echo "Set initial password $INITIAL_PASSWORD for $USERNAME"
echo -e "${INITIAL_PASSWORD}\n${INITIAL_PASSWORD}\n" | ipa user-mod ${USERNAME} --password

echo "Change password so $USERNAME can log in"
PASSWORD=$(openssl rand -base64 12)
echo -e "${INITIAL_PASSWORD}\n${PASSWORD}\n${PASSWORD}\n" | kinit ${USERNAME} -c /tmp/null

echo -e "Created ${USERNAME} with password:\n${PASSWORD}"