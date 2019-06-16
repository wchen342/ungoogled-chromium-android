#!/usr/bin/env bash
set -eux -o pipefail

chromium_version=74.0.3729.169

# Required tools: python2, python3, ninja, git, clang, lld, llvm, curl
# Assuming default python to be python2. This is true on most Linux distributions.

## Clone ungoogled-chromium repo
git clone https://github.com/Eloston/ungoogled-chromium.git -b $chromium_version-1

## Clone chromium repo
git clone --depth 1 --no-tags https://chromium.googlesource.com/chromium/src.git -b $chromium_version

## Fetch depot-tools
depot_tools_commit=$(grep 'depot_tools.git' src/DEPS | cut -d\' -f8)
mkdir -p depot_tools
pushd depot_tools
git init
git remote add origin https://chromium.googlesource.com/chromium/tools/depot_tools.git
git fetch --depth 1 --no-tags origin $depot_tools_commit
git reset --hard FETCH_HEAD
popd
export PATH="$(pwd -P)/depot_tools:$PATH"


## Sync files
## need .gclient under same folder
gclient.py sync --nohooks --no-history --shallow --revision=$chromium_version


## Fix repos
feed_commit=$(grep "'feed_revision':" src/DEPS | cut -d\' -f4)
mkdir src/third_party/feed/src
pushd src/third_party/feed/src
git init
git remote add origin https://chromium.googlesource.com/feed
git fetch --depth 1 --no-tags origin $feed_commit
git reset --hard FETCH_HEAD
popd

webrtc_commit=$(grep 'webrtc_git.*/src\.git' src/DEPS | cut -d\' -f8)
mkdir src/third_party/webrtc
pushd src/third_party/webrtc
git init
git remote add origin https://webrtc.googlesource.com/src.git
git fetch --depth 1 --no-tags origin $webrtc_commit
git reset --hard FETCH_HEAD
popd

libsync_commit=$(grep 'libsync\.git' src/DEPS | cut -d\' -f10)
mkdir src/third_party/libsync/src
pushd src/third_party/libsync/src
git init
git remote add origin https://chromium.googlesource.com/aosp/platform/system/core/libsync.git
git fetch --depth 1 --no-tags origin $libsync_commit
git reset --hard FETCH_HEAD
popd

GN_COMMIT=9bd94208ec741659d5126b990fdccd35a5c30b1f
mv src/tools/gn src/tools/gn.bak
git clone https://gn.googlesource.com/gn src/tools/gn
pushd src/tools/gn
git checkout $GN_COMMIT
popd
cp -r src/tools/gn.bak/bootstrap src/tools/gn


## Hooks
python src/build/util/lastchange.py -o src/build/util/LASTCHANGE
python src/chrome/android/profiles/update_afdo_profile.py
python src/build/util/lastchange.py -m GPU_LISTS_VERSION --revision-id-only --header src/gpu/config/gpu_lists_version.h
python src/build/util/lastchange.py -m SKIA_COMMIT_HASH -s src/third_party/skia --header src/skia/ext/skia_commit_hash.h


## Run ungoogled-chromium scripts
# Patch prune list and domain substitution
# TODO some pruned binaries are excluded since they will cause android build to fail
patch -p1 --ignore-whitespace -i patches/android-prune-domain-fix.patch --no-backup-if-mismatch
# Remove the cache file if exists
cache_file=domsubcache.tar.gz
if [ -f $cache_file ] ; then
    rm $cache_file
fi

# Ignore the pruning error
python3 ungoogled-chromium/utils/prune_binaries.py src ungoogled-chromium/pruning.list || true
python3 ungoogled-chromium/utils/patches.py apply src ungoogled-chromium/patches
python3 ungoogled-chromium/utils/domain_substitution.py apply -r ungoogled-chromium/domain_regex.list -f ungoogled-chromium/domain_substitution.list -c $cache_file src


## Extra fixes for Chromium source
## Fix an error in chrome/browser/android/rlz/rlz_ping_handler.cc: line 79, -rlz_lib::kFinancialServer +"about:blank"
patch -p1 --ignore-whitespace -i patches/android-rlz-fix-missing-variable.patch --no-backup-if-mismatch
## Workaround for a building failure caused by safe browsing. The file is pre-generated with safe_browsing_mode=2. See https://github.com/nikolowry/bromite-builder/issues/1
# x86
mkdir -p src/out/Default/gen/chrome/common/safe_browsing
cp download_file_types.pb.h src/out/Default/gen/chrome/common/safe_browsing
# arm/arm64
cp download_file_types.pb.h src/chrome/common/safe_browsing/download_file_types.pb.h


## Set compiler flags
export AR=${AR:=llvm-ar}
export NM=${NM:=llvm-nm}
export CC=${CC:=clang}
export CXX=${CXX:=clang++}


## Genarate gn file
pushd src/tools/gn
build/gen.py
ninja -C out gn
popd


## Prepare Android SDK/NDK
## This is Sylvain Beucler's libre Android rebuild
sdk_link="https://android-rebuilds.beuc.net/dl/android-sdk_user.9.0.0_r21_linux-x86.zip"
ndk_link="https://android-rebuilds.beuc.net/dl/android-ndk-r18b-linux-x86_64.tar.bz2"
mkdir android-rebuilds
mkdir android-sdk
mkdir android-ndk
cd android-rebuilds && { curl -O $sdk_link ; curl -O $ndk_link ; cd -; }
unzip -qqo android-rebuilds/android-sdk_user.9.0.0_r21_linux-x86.zip -d android-sdk
tar xjf android-rebuilds/android-ndk-r18b-linux-x86_64.tar.bz2 -C android-ndk
# remove data_space.h, patch native_window.h
mv android-ndk/android-ndk-r18b/sysroot/usr/include/android/data_space.h android-ndk/android-ndk-r18b/sysroot/usr/include/android/data_space.h.bak
patch -p1 --ignore-whitespace -i patches/ndk-native-window.patch --no-backup-if-mismatch
# Create symbol links to sdk folders
# The rebuilt sdk has a different folder structure from the checked out version, so it is easier to create symbol links 
# Currently extras and tools are not available from the rebuild
pushd src/third_party/android_tools/sdk
rm -rf add-ons emulator licenses platforms sources tools-lint build-tools ndk-bundle platform-tools
mkdir build-tools
ln -s ../../../../../android-sdk/android-sdk_user.9.0.0_r21_linux-x86/build-tools/android-9 build-tools/27.0.3
mkdir platforms
ln -s ../../../../../android-sdk/android-sdk_user.9.0.0_r21_linux-x86/platforms/android-9 platforms/android-28
ln -s ../../../../android-sdk/android-sdk_user.9.0.0_r21_linux-x86/platform-tools platform-tools
popd


## Configure output folder
## patch build/config/android/BUILD.gn
patch -p1 --ignore-whitespace -i patches/linker-android-support-remove.patch --no-backup-if-mismatch
cd src
mkdir -p out/Default
cat ../ungoogled-chromium/flags.gn ../android_flags.gn > out/Default/args.gn
tools/gn/out/gn gen out/Default --fail-on-unused-args


## Build
ninja -C out/Default monochrome_public_apk

