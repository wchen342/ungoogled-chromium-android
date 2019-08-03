#!/usr/bin/env bash
set -eux -o pipefail

chromium_version=76.0.3809.87
target=monochrome_public_apk

# Required tools: python2, python3, ninja, git, clang, lld, llvm, curl
# Assuming default python to be python2. This is true on most Linux distributions.

## Clone ungoogled-chromium repo
git clone https://github.com/Eloston/ungoogled-chromium.git -b ${chromium_version}-1

## Clone chromium repo
git clone --depth 1 --no-tags https://chromium.googlesource.com/chromium/src.git -b ${chromium_version}

## Fetch depot-tools
depot_tools_commit=$(grep 'depot_tools.git' src/DEPS | cut -d\' -f8)
mkdir -p depot_tools
pushd depot_tools
git init
git remote add origin https://chromium.googlesource.com/chromium/tools/depot_tools.git
git fetch --depth 1 --no-tags origin ${depot_tools_commit}
git reset --hard FETCH_HEAD
popd
export PATH="$(pwd -P)/depot_tools:$PATH"


## Sync files
# third_party/android_deps and some other overrides doesn't work
gclient.py sync --nohooks --no-history --shallow --revision=${chromium_version}


## Fix repos
feed_commit=$(grep "'feed_revision':" src/DEPS | cut -d\' -f4)
mkdir src/third_party/feed/src
pushd src/third_party/feed/src
git init
git remote add origin https://chromium.googlesource.com/feed
git fetch --depth 1 --no-tags origin ${feed_commit}
git reset --hard FETCH_HEAD
popd

webrtc_commit=$(grep 'webrtc_git.*/src\.git' src/DEPS | cut -d\' -f8)
mkdir src/third_party/webrtc
pushd src/third_party/webrtc
git init
git remote add origin https://webrtc.googlesource.com/src.git
git fetch --depth 1 --no-tags origin ${webrtc_commit}
git reset --hard FETCH_HEAD
popd

libsync_commit=$(grep 'libsync\.git' src/DEPS | cut -d\' -f10)
mkdir src/third_party/libsync/src
pushd src/third_party/libsync/src
git init
git remote add origin https://chromium.googlesource.com/aosp/platform/system/core/libsync.git
git fetch --depth 1 --no-tags origin ${libsync_commit}
git reset --hard FETCH_HEAD
popd

gn_commit=9bd94208ec741659d5126b990fdccd35a5c30b1f
mv src/tools/gn src/tools/gn.bak
git clone https://gn.googlesource.com/gn src/tools/gn
pushd src/tools/gn
git checkout ${gn_commit}
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
cache_file="domsubcache.tar.gz"
if [[ -f ${cache_file} ]] ; then
    rm ${cache_file}
fi

# Ignore the pruning error
python3 ungoogled-chromium/utils/prune_binaries.py src ungoogled-chromium/pruning.list || true
python3 ungoogled-chromium/utils/patches.py apply src ungoogled-chromium/patches
python3 ungoogled-chromium/utils/domain_substitution.py apply -r ungoogled-chromium/domain_regex.list -f ungoogled-chromium/domain_substitution.list -c ${cache_file} src


# Workaround for a building failure caused by safe browsing. The file is pre-generated with safe_browsing_mode=2. See https://github.com/nikolowry/bromite-builder/issues/1
# arm/arm64
cp download_file_types.pb.h src/chrome/common/safe_browsing/download_file_types.pb.h


## Prepare Android SDK/NDK
# This is Sylvain Beucler's libre Android rebuild
sdk_link="https://android-rebuilds.beuc.net/dl/android-sdk_user.9.0.0_r21_linux-x86.zip"
sdk_tools_link="https://android-rebuilds.beuc.net/dl/sdk-repo-linux-tools-26.1.1.zip"
ndk_link="https://android-rebuilds.beuc.net/dl/android-ndk-r18b-linux-x86_64.tar.bz2"
mkdir android-rebuilds
mkdir android-sdk
mkdir android-ndk
cd android-rebuilds && { curl -O ${sdk_link} ; curl -O ${sdk_tools_link} ; curl -O ${ndk_link} ; cd -; }
unzip -qqo android-rebuilds/android-sdk_user.9.0.0_r21_linux-x86.zip -d android-sdk
unzip -qqo android-rebuilds/sdk-repo-linux-tools-26.1.1.zip -d android-sdk/android-sdk_user.9.0.0_r21_linux-x86
tar xjf android-rebuilds/android-ndk-r18b-linux-x86_64.tar.bz2 -C android-ndk
# remove data_space.h, patch native_window.h
mv android-ndk/android-ndk-r18b/sysroot/usr/include/android/data_space.h android-ndk/android-ndk-r18b/sysroot/usr/include/android/data_space.h.bak
patch -p1 --ignore-whitespace -i patches/ndk-native-window.patch --no-backup-if-mismatch
# Create symbol links to sdk folders
# The rebuild sdk has a different folder structure from the checked out version, so it is easier to create symbol links
# Old aapt no longer works. Need to use Maven version until a rebuild of SDK 29 exists.
#pushd src/third_party/android_build_tools
#rm -rf aapt2
#ln -s ../../../android-sdk/android-sdk_user.9.0.0_r21_linux-x86/build-tools/android-9 aapt2
#popd
DIRECTORY="src/third_party/android_sdk/public"
if [[ -d "$DIRECTORY" ]]; then
  rm -rf "$DIRECTORY"
fi
mkdir "${DIRECTORY}" && pushd ${DIRECTORY}
# rm -rf add-ons emulator licenses platforms sources tools-lint build-tools ndk-bundle platform-tools tools
mkdir build-tools && ln -s ../../../../../android-sdk/android-sdk_user.9.0.0_r21_linux-x86/build-tools/android-9 build-tools/27.0.3
mkdir platforms
ln -s ../../../../../android-sdk/android-sdk_user.9.0.0_r21_linux-x86/platforms/android-9 platforms/android-28
ln -s ../../../../android-sdk/android-sdk_user.9.0.0_r21_linux-x86/platform-tools platform-tools
ln -s ../../../../android-sdk/android-sdk_user.9.0.0_r21_linux-x86/tools tools
popd


## Compile third-party binaries
# error-prone, from Maven repo
mkdir -p src/third_party/errorprone/lib
pushd src/third_party/errorprone/lib
version=2.3.1
mvn_url="https://repo1.maven.org/maven2/com/google/errorprone/error_prone_ant/${version}"
curl "${mvn_url}/error_prone_ant-${version}.jar" -O
curl "${mvn_url}/error_prone_ant-${version}.jar.asc" -O
echo -e "\033[0;33mThis will add a new key to your GPG keyring! \033[0m"
gpg --recv-keys EE9E7DC9D92FC896
gpg --verify "error_prone_ant-${version}.jar.asc" "error_prone_ant-${version}.jar"
popd
# closure-compiler
DIRECTORY="src/third_party/closure_compiler"
mkdir "${DIRECTORY}"/temp && pushd ${DIRECTORY}/temp
git clone https://github.com/google/closure-compiler && cd closure-compiler
mvn -DskipTests -pl externs/pom.xml,pom-main.xml,pom-main-shaded.xml
cp -a target/closure-compiler-1.0-SNAPSHOT.jar ../../compiler/compiler.jar
cd ../.. && rm -rf temp
popd
# eu-strip can be re-compiled with -Wno-error, but it is probably not a good idea
patch -p1 --ignore-whitespace -i patches/eu-strip-build-script.patch --no-backup-if-mismatch
pushd src/buildtools/third_party/eu-strip
./build.sh
popd
# Some of the support libraries can be grabbed from maven https://android.googlesource.com/platform/prebuilts/maven_repo/android/+/master/com/android/support/


# Additional Source Patches
# TODO use patches.py instead
## Extra fixes for Chromium source
#patch -p1 --ignore-whitespace -i patches/android-rlz-fix-missing-variable.patch --no-backup-if-mismatch    # Fix an error in chrome/browser/android/rlz/rlz_ping_handler.cc
#patch -p1 --ignore-whitespace -i patches/fix-redefinition-error.patch --no-backup-if-mismatch    # Fix a redefinition error
#patch -p1 --ignore-whitespace -i patches/change_package_name.patch --no-backup-if-mismatch    # Change package/App name
#patch -p1 --ignore-whitespace -i patches/Vanadium/0020-disable-media-router-media-remoting-by-default.patch --no-backup-if-mismatch
#patch -p1 --ignore-whitespace -i patches/Vanadium/0021-disable-media-router-by-default.patch --no-backup-if-mismatch
#patch -p1 --ignore-whitespace -i patches/linker-android-support-remove.patch --no-backup-if-mismatch
#patch -p1 --ignore-whitespace -i patches/aapt2-param.patch --no-backup-if-mismatch
## Second pruning list
pruning_list_2="pruning_2.list"
python3 ungoogled-chromium/utils/prune_binaries.py src ${pruning_list_2} || true
## Second domain substitution list
substitution_list_2="domain_sub_2.list"
# Remove the cache file if exists
cache_file="domsubcache.tar.gz"
if [[ -f ${cache_file} ]] ; then
    rm ${cache_file}
fi
python3 ungoogled-chromium/utils/domain_substitution.py apply -r ungoogled-chromium/domain_regex.list -f ${substitution_list_2} -c ${cache_file} src


## Genarate gn file
pushd src/tools/gn
build/gen.py
ninja -C out gn
popd


## Configure output folder
cd src
mkdir -p out/Default
cat ../ungoogled-chromium/flags.gn ../android_flags.gn > out/Default/args.gn
tools/gn/out/gn gen out/Default --fail-on-unused-args


## Set compiler flags
export AR=${AR:=llvm-ar}
export NM=${NM:=llvm-nm}
export CC=${CC:=clang}
export CXX=${CXX:=clang++}

## Build
ninja -C out/Default ${target}
