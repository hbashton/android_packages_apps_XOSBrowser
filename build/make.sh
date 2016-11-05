#!/bin/bash

LOCAL_REPO="$(dirname $(readlink -f $0)))"
ROMName=$(basename $LOCAL_REPO)
export GYP_CHROMIUM_NO_ACTION=1

# errors on
set -e

# parameter "--system" allows not to start the build immdeiately
# parameter "--no-gn" allows not to run "gclient runhooks -v" - to check the pervious commits logs
isCustom="$1"

cd $LOCAL_REPO/src

git apply $LOCAL_REPO/build/patches/halogenOS.patch && git add -f $(git status -s | awk '{print $2}') && git commit -m "This is XOS Browser"

if [[ "$isCustom" != "--no-gn" ]];
then
  . build/android/envsetup.sh
  gn gen out/Default --args='target_os="android" ffmpeg_branding="Chrome" proprietary_codecs=true enable_nacl=false is_debug=false is_component_build=false target_cpu="arm"'
else
  exit 0
fi

# for ROM build env - to allow it starting system package build itself
if [[ "$isCustom" != "--system" ]];
then
  $LOCAL_REPO/build/run.sh &
fi
