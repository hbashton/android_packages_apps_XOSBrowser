#!/bin/bash

function asktocontinue() {
read -p "$1 ([y]es or [N]o): "
    case $(echo -e $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}

LOCAL_REPO="$(dirname $(dirname $(readlink -f $0)))"
#Colors
source $LOCAL_REPO/build/colors.sh

echo -e "${Blu}You are now building XOS Browser!"

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

echo -e "${Yel}Cleaning the source and halogen-ifying it"
# errors on

OUTFOLDER=$(date +%d%m)
value=$( git log -1 | grep -c "XOS" )

cd $LOCAL_REPO/src
	rm -rf $LOCAL_REPO/src/out
	git clean -f -d
if [ $value -eq "0" ] 
then
	git reset --hard HEAD
fi
if [ $value -eq "1" ] 
then
        git reset --hard HEAD~1
fi
        git checkout HEAD
	git fetch origin
	git checkout  origin/m55
        gclient sync -f
	git am -3 < ../build/patches/halogenOS.patch

  	. build/android/envsetup.sh
  	gn gen out/$OUTFOLDER --args='target_os="android" ffmpeg_branding="Chrome" proprietary_codecs=true enable_nacl=false is_debug=false is_component_build=false target_cpu="arm"'

if [ "no" == $(asktocontinue "Would you like to start the build now?") ]
then
    echo "Skipped."
    exit 0
fi

LogsDir="$HOME/logs"

if [ ! -d "$LogsDir" ]; then
  echo -e "\n"$(date +%D\ %T) "${Blu}Logs directory '$LogsDir' not found, creating it..."
  mkdir -p "$LogsDir"
fi

cd $LOCAL_REPO/src
time ninja -C out/$OUTFOLDER swe_browser_apk | tee $LogsDir/$OUTFOLDER_XOS.txt
