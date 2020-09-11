#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f $BASH_SOURCE[0]))

#set -x
trap '[ "$?" -ne 77 ] || exit 1' ERR

USAGE="create_kac_user.sh PROJECT FIRSTNAME LASTNAME USERNAME EMAIL PHONE"

echo "Validating parameters $*"
PROJECT="$1"
[ -n "${PROJECT}" ] || (>&2 echo "$USAGE" &&  exit 77)
FIRSTNAME="$2"
[ -n "${FIRSTNAME}" ] || (>&2 echo "$USAGE" &&  exit 77)
LASTNAME="$3"
[ -n "${LASTNAME}" ] || (>&2 echo "$USAGE" &&  exit 77)
USERNAME="$4"
[ -n "${USERNAME}" ] || (>&2 echo "$USAGE" &&  exit 77)
EMAIL="$5"
[ -n "${EMAIL}" ] || (>&2 echo "$USAGE" &&  exit 77)
PHONE="$6"
[ -n "${PHONE}" ] || (>&2 echo "$USAGE" &&  exit 77)



echo "Validating this host $(hostname)"
hostname | grep kac-adm-001 || (>&2 echo 'must be executed on host kac-adm-001' && exit 77)

EMAIL_PROBLEM=n
echo "Checking if email $EMAIL is already used by a member of this group $PROJECT"
ipa group-show ${PROJECT} | grep -F 'Member users' | cut -d':' -f2 | sed 's/,/\n/g' | xargs -r -i bash -c 'echo -ne "{} "; ipa user-show {} | grep Email | cut -d":" -f2' | grep  " ${EMAIL}$" && EMAIL_PROBLEM=y && read -n 1 -p "Email is already present in this group, continue? [y/n] " IGNORE_EMAIL_PRESENT

if [ $EMAIL_PROBLEM == "y" ] && [ "$IGNORE_EMAIL_PRESENT" != "y" ]; then
  exit 1
fi


echo "Get the group from the project name '$PROJECT'"
group=$(ipa group-find --group-name=${PROJECT} --posix  | grep "GID:" | cut -d':' -f2 | sed 's/ //g')
if [ -z "$group" ]; then
    echo "you must create group with 'ipa group-add $PROJECT --gid=<GID>' before using this script"
    exit 1
fi
echo "Found GID for project to be $group"

echo "Checking if $USERNAME already exists"
ipa user-find --login="${USERNAME}" --pkey-only > /dev/null && (echo "User $USERNAME already exists, aborting" && exit 77)

echo "$USERNAME does not exist"

echo "Find next available UID, starting from GID=$group"
uid=$((group+1))
while ipa user-find --uid=${uid} --pkey-only &>/dev/null; do
    uid=$((uid+1));
done
echo "uid=$uid have been chosen for the new user $USERNAME"


echo "Create the user $USERNAME in FreeIPA"
ipa user-add \
    --first="$FIRSTNAME" \
    --last="$LASTNAME" \
    --homedir="/home/${USERNAME}" \
    --phone="$PHONE" \
    --uid=${uid} \
    --shell="/bin/bash" \
    --gidnumber=${uid} \
    --class="KacUser" \
    --email="$EMAIL" \
    -- \
    ${USERNAME}

echo "$USERNAME joins the relevant groups"
ipa group-add-member --user "${USERNAME}" -- "$PROJECT"
ipa group-add-member --user "${USERNAME}" -- kacusers
ipa group-add-member --user "${USERNAME}" -- vpnu

echo "Refreshing sss-cache to get the user to exist in unix"
sudo sss_cache -E

echo "Make user home dir /data/home/$USERNAME"
sudo mkdir -p -- "/data/home/${USERNAME}"
sudo cp -u -- /etc/skel/.bash* "/data/home/${USERNAME}/"
sudo chown -R -- "${uid}:${uid}" "/data/home/${USERNAME}"
sudo chmod  -o-rwx -- /data/home/${USERNAME}"

INITIAL_PASSWORD=$(openssl rand -base64 25)
echo "Set initial password $INITIAL_PASSWORD for $USERNAME"
echo -e "${INITIAL_PASSWORD}\n${INITIAL_PASSWORD}\n" | ipa user-mod --password -- "${USERNAME}"

echo "Change password so $USERNAME can log in"
PASSWORD=$($SCRIPT_DIR/../kac-kerberos/bin/passPhraseGen.sh \
	-j '' \
	-c \
	-l 1 \
	-f "$SCRIPT_DIR/../kac-kerberos/bin/wordlists/dansk-ordliste-unum.txt" \
	-m 25)
echo -e "${INITIAL_PASSWORD}\n${PASSWORD}\n${PASSWORD}\n" | kinit -c /tmp/null -- "${USERNAME}"

echo -e "Created ${USERNAME} with password:\n${PASSWORD}"
