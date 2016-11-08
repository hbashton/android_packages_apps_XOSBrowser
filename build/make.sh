#!/bin/bash
LOCAL_REPO="$(dirname $(dirname $(readlink -f $0)))"
#Colors
source $LOCAL_REPO/build/colors.sh

echo -e "${Blu}You are now building XOS Browser!"

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

echo -e "${Yel}Cleaning the source and halogen-ifying it"
# errors on
set -e
OUTFOLDER=$(date +%d%m)
# parameter "--system" allows not to start the build immdeiately
# parameter "--no-gn" allows not to run "gclient runhooks -v" - to check the pervious commits logs

cd $LOCAL_REPO/src
	rm -rf $LOCAL_REPO/src/out
	git clean -f -d
	git reset --hard HEAD
	git fetch origin
	git checkout origin/m55
	git apply $LOCAL_REPO/build/patches/halogenOS.patch && git add -f $(git status -s | awk '{print $2}') && git commit -m "This is XOS Browser"

  	. build/android/envsetup.sh
  	gn gen out/$OUTFOLDER --args='target_os="android" ffmpeg_branding="Chrome" proprietary_codecs=true enable_nacl=false is_debug=false is_component_build=false target_cpu="arm"'


function asktocontinue() {
read -p "$1 ([y]es or [N]o): "
    case $(echo -e $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}

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
