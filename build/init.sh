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
if [ -f $LOCAL_REPO/build/make.config ]
then
. $LOCAL_REPO/build/make.config
else
export DEPOT_TOOLS_DIR=$HOME/depot_tools
fi
if [ -d "$DEPOT_TOOLS_DIR" ]; then

echo -e "${Yel}Found Depot Tools, adding to path"
export PATH="$PATH":$HOME/depot_tools
else

echo -e "${Yel}Could not find $DEPOT_TOOLS. If you have it somewhere else, add it to your home directory, or make a 'make.config' file in the build folder."

   if [ "no" == $(asktocontinue "Would you like to clone depot_tools to your home directory?") ]
   then
   echo "Please configure the location of your depot tools in $LOCAL_REPO/build/make.config, or just clone to your home directory."
   exit 0
   else
git clone git://codeaurora.org/quic/chrome4sdp/chromium/tools/depot_tools.git $HOME
   fi

echo -e "${Yel}Adding $DEPOT_TOOLS to path"
export PATH="$PATH":$HOME/depot_tools
fi


echo -e "${Yel}Beginning gclient sync. This may take awhile, so sit back and enjoy the terminal"
gclient sync
cd src
echo -e "S{Yel}Installing Android build dependencies"
./build/install-build-deps-android.sh
echo -e "${Yel}All done! Now, run ./build/make.sh"
exit 0
