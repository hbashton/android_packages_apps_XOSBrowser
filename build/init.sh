export GYP_CHROMIUM_NO_ACTION=1 # don't process gyp

if [ -d src -a -f src/DEPS ]; then
    cd src
    MAJOR_VER=$(cat swe/VERSION | grep -e ^MAJOR\=)
    MAJOR_VER=${MAJOR_VER#MAJOR=}
    SYNC_RET=$(git pull origin m$MAJOR_VER)
    SYNC_RET=$(echo "$SYNC_RET" | grep 'up-to-date')
    if [ $# -gt 0 ] && [ $1 = "force" ]; then
        SYNC_RET=1
    elif [ ${#SYNC_RET} -eq 0 ]; then
        SYNC_RET=1
    else
        SYNC_RET=
    fi

    cd ..
    if [ $SYNC_RET ]; then
        gclient sync -n --no-nag-max
    fi
else
    gclient sync -n --no-nag-max
    cd src
    ./build/install-build-deps-android.sh
    . ./build/android/envsetup.sh
fi


