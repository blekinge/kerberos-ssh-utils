#!/usr/bin/env bash

#Small script unconnected to the rest of this repo, to get relevant info about your machine

set -e
echo "Testing prerequisites"
echo "  dmidecode version=$(dmidecode --version)"
echo "  lshw version=$(lshw -version)"
echo "  xmllint version=$(xmllint --version 2>&1| head -1)"
echo "  sed version=$(sed --version | head -1)"
echo "  jq version=$(jq --version | head -1)"
echo "  curl version=$(curl --version | head -1)"
echo "  git version=$(git --version | head -1)"
echo "  git configured email=$(git config --get 'user.email')"

echo ""
echo "Machine data"
echo "------------"

echo "  Hostname=$(hostname)"
echo '  HW-model='$(sudo dmidecode -s system-product-name)
#echo ' HW-model='$(sudo lshw -xml | xmllint --xpath "/list/node[@class='system']/product/text()" -)
echo '  Serienummer='$(sudo dmidecode -s system-serial-number)
#echo ' Serienummer='sudo lshw -xml | xmllint --xpath "/list/node[@class='system']/serial/text()" -)

#echo ' MAC Addresser='$(lshw -C network -xml 2>/dev/null | xmllint --xpath "/list/node[configuration/setting[@id='driver']/@value!='bridge']/serial" - | sed 's/></>,</' | sed 's|<[^>]*>||g')
echo '  MAC Addresser='$(lshw -xml 2>/dev/null| xmllint --xpath "//node[@id='network']/serial" - | sed 's/></>,</' | sed 's|<[^>]*>||g')

echo "  Kontor="$(curl -s -- "http://hyperion:8381/spot/services/medarbejder/search/$(git config --get user.email)" | jq '.medarbejdere[0].location' -r)