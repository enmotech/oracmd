#!/bin/sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/enmotech/oracmd/master/install.sh)"
# or wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/enmotech/oracmd/master/install.sh)"

repo=enmotech/oracmd
hardware=`uname -m`
osType=`uname`
workdir=`pwd`
oracmdDir=$workdir/oracmd

if [[ $hardware == "x86_64" ]]; then
    osArch="amd64"
elif [[ $hardware == "aarch64" ]]; then
    osArch="arm64"
else
    osArch="i386"
fi



get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}


get_download_url() {
curl --silent "https://api.github.com/repos/${repo}/releases/latest" \
  | grep "browser_download_url"  | grep "oracmd" \
  | grep -i ${osType} | grep -i ${osArch} \
  | cut -d ":" -f 2,3 \
  | tr -d \"

}


ORACMD_VERSION=$(get_latest_release $repo)

echo "The Version: $ORACMD_VERSION"

echo "Installing version $ORACMD_VERSION"

URL=$(get_download_url $repo)
BASE=$(basename $URL)

echo "Download File: $BASE"
echo "Download URL: $URL"

wget -q -nv -O $BASE $URL

if [ ! -f $BASE ]; then
	echo "Didn't download $URL properly.  Where is $BASE?"
	exit 1
fi


tar -zxf $BASE

chmod +x ${oracmdDir}/bin/oracmd

echo "oracmd binary location: ${oracmdDir}/bin/oracmd"



echo "New oracmd binary version installed!"

oracmd/bin/oracmd version
