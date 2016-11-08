#!/bin/bash
LOCAL_REPO="$(dirname $(dirname $(readlink -f $0)))"
#Colors
source $LOCAL_REPO/build/colors.sh
set -e
echo -e "${Blu}Setting up build environment"

echo -e "${Blu}Setting $LOCAL_REPO as the local directory"
ROMName=$(basename $LOCAL_REPO)

echo -e "${Yel}Disabling GYP"
export GYP_CHROMIUM_NO_ACTION=1
export DEPOT_TOOLS_DIR=$HOME/depot_tools
if [ -d "$DEPOT_TOOLS_DIR" ]; then

echo -e "${Yel}Found Depot Tools, adding to path"
export PATH="$PATH":$HOME/depot_tools
else

echo -e "${Red}Could not find $DEPOT_TOOLS. Downloading from git. If you have it somewhere else, add it to your home directory."
git clone git://codeaurora.org/quic/chrome4sdp/chromium/tools/depot_tools.git $HOME

echo -e "${Yel}Adding $DEPOT_TOOLS to path"
export PATH="$PATH":$HOME/depot_tools
fi

echo -e "{Yel}Beginning gclient sync. This may take awhile, so sit back and enjoy the terminal"
gclient sync
cd src
echo -e "S{Yel}Installing Android build dependencies"
./build/install-build-deps-android.sh
echo -e "${Yel}All done! Now, run ./build/init.sh"
exit 0
