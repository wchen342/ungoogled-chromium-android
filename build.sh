#!/usr/bin/env bash
set -eux -o pipefail

chrome_target=chrome_public_apk
mono_target=monochrome_public_apk
webview_target=system_webview_apk

chromium_version=79.0.3945.117
ungoogled_chromium_revision=1

# Argument parser from https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash/29754866#29754866
# -allow a command to fail with !’s side effect on errexit
# -use return value from ${PIPESTATUS[0]}, because ! hosed $?
! getopt --test > /dev/null 
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo 'I’m sorry, `getopt --test` failed in this environment.'
    exit 1
fi

OPTIONS=a:t:
LONGOPTS=arch:,target:

# -regarding ! and PIPESTATUS see above
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

ARCH=- TARGET=-

# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -a|--arch)
            ARCH="$2"
            shift 2
            ;;
        -t|--target)
            TARGET="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

if [[ "$ARCH" != "arm64" ]] && [[ "$ARCH" != "arm" ]] && [[ "$ARCH" != "x86" ]]; then
    echo "Wrong architecture"
    exit 4
fi

if [[ "$TARGET" != "$chrome_target" ]] && [[ "$TARGET" != "$mono_target" ]] && [[ "$TARGET" != "$webview_target" ]]; then
    echo "Wrong target"
    exit 5
fi

echo "arch: $ARCH, target: $TARGET"

# Required tools: protobuf python python2 gperf wget rsync tar unzip curl gnupg maven yasm npm ninja git clang lld gn llvm openjdk lib32-glibc multilib-devel
# Assuming default python to be python2.

## Clone ungoogled-chromium repo
git clone https://github.com/Eloston/ungoogled-chromium.git -b ${chromium_version}-${ungoogled_chromium_revision}

## Clone chromium repo
git clone --depth 1 --no-tags https://chromium.googlesource.com/chromium/src.git -b ${chromium_version}

## Fetch depot-tools
depot_tools_commit=$(grep 'depot_tools.git' src/DEPS | cut -d\' -f8)
mkdir -p depot_tools
pushd depot_tools
git init
git remote add origin https://chromium.googlesource.com/chromium/tools/depot_tools.git
git fetch --depth 1 --no-tags origin "${depot_tools_commit}"
git reset --hard FETCH_HEAD
popd
export PATH="$(pwd -P)/depot_tools:$PATH"
pushd src/third_party
ln -s ../../depot_tools
popd


## Sync files
# third_party/android_deps and some other overrides doesn't work
gclient.py sync --nohooks --no-history --shallow --revision=${chromium_version}


## Fix repos
feed_commit=$(grep "'feed_revision':" src/DEPS | cut -d\' -f4)
mkdir src/third_party/feed/src
pushd src/third_party/feed/src
git init
git remote add origin https://chromium.googlesource.com/feed
git fetch --depth 1 --no-tags origin "${feed_commit}"
git reset --hard FETCH_HEAD
popd

webrtc_commit=$(grep 'webrtc_git.*/src\.git' src/DEPS | cut -d\' -f8)
mkdir src/third_party/webrtc
pushd src/third_party/webrtc
git init
git remote add origin https://webrtc.googlesource.com/src.git
git fetch --depth 1 --no-tags origin "${webrtc_commit}"
git reset --hard FETCH_HEAD
popd

libsync_commit=$(grep 'libsync\.git' src/DEPS | cut -d\' -f10)
mkdir src/third_party/libsync/src
pushd src/third_party/libsync/src
git init
git remote add origin https://chromium.googlesource.com/aosp/platform/system/core/libsync.git
git fetch --depth 1 --no-tags origin "${libsync_commit}"
git reset --hard FETCH_HEAD
popd

gn_commit=2426c173819e74a9dad7a2ab647cfa1506f6007f
mv src/tools/gn src/tools/gn.bak
git clone https://gn.googlesource.com/gn src/tools/gn
pushd src/tools/gn
git checkout ${gn_commit}
popd
cp -r src/tools/gn.bak/bootstrap src/tools/gn

## Hooks
python src/build/util/lastchange.py -o src/build/util/LASTCHANGE
python src/tools/download_cros_provided_profile.py --newest_state=src/chrome/android/profiles/newest.txt --local_state=src/chrome/android/profiles/local.txt --output_name=src/chrome/android/profiles/afdo.prof --gs_url_base=chromeos-prebuilt/afdo-job/llvm
python src/build/util/lastchange.py -m GPU_LISTS_VERSION --revision-id-only --header src/gpu/config/gpu_lists_version.h
python src/build/util/lastchange.py -m SKIA_COMMIT_HASH -s src/third_party/skia --header src/skia/ext/skia_commit_hash.h
# New binary dependency: node, caused by webui
src/third_party/node/update_node_binaries
src/third_party/node/update_npm_deps


## Run ungoogled-chromium scripts
# Patch prune list and domain substitution
# TODO some pruned binaries are excluded since they will cause android build to fail
patch -p1 --ignore-whitespace -i patches/android-prune-fix.patch --no-backup-if-mismatch
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
cp safe_browsing_proto_files/download_file_types.pb.h src/chrome/common/safe_browsing/download_file_types.pb.h
cp safe_browsing_proto_files/webprotect.pb.h src/components/safe_browsing/proto/webprotect.pb.h


## Prepare Android SDK/NDK

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
mkdir build-tools && ln -s ../../../../../android-sdk/android-sdk_user.9.0.0_r21_linux-x86/build-tools/android-9 build-tools/29.0.2
mkdir platforms
ln -s ../../../../../android-sdk/android-sdk_user.9.0.0_r21_linux-x86/platforms/android-9 platforms/android-28
ln -s ../../../../android-sdk/android-sdk_user.9.0.0_r21_linux-x86/platform-tools platform-tools
ln -s ../../../../android-sdk/android-sdk_user.9.0.0_r21_linux-x86/tools tools
popd

# remove ndk folders
DIRECTORY="src/third_party/android_ndk"
gn_file="BUILD.gn"
mkdir "temp"
#cp -a "${DIRECTORY}/${gn_file}" android-ndk/android-ndk-r20b
#cp -ar "${DIRECTORY}/toolchains/llvm/prebuilt/linux-x86_64" android-ndk/android-ndk-r20b/toolchains/llvm/prebuilt    # Need libgcc.a otherwise compilation will fail
cp -a "${DIRECTORY}/${gn_file}" temp
cp -ar "${DIRECTORY}/toolchains/llvm/prebuilt/linux-x86_64" temp    # Need libgcc.a otherwise compilation will fail
pushd "${DIRECTORY}"
cd ..
rm -rf android_ndk
ln -s ../../android-ndk/android-ndk-r20b android_ndk
popd

# This is Sylvain Beucler's libre Android rebuild
sdk_link="https://android-rebuilds.beuc.net/dl/bundles/android-sdk_user.9.0.0_r21_linux-x86.zip"
sdk_tools_link="https://android-rebuilds.beuc.net/dl/repository/sdk-repo-linux-tools-26.1.1.zip"
ndk_link="https://android-rebuilds.beuc.net/dl/repository/android-ndk-r20b-linux-x86_64.tar.bz2"

sdk_tools_link="https://android-rebuilds.beuc.net/dl/repository/sdk-repo-linux-tools-26.1.1.zip"
ndk_link="https://android-rebuilds.beuc.net/dl/repository/android-ndk-r20b-linux-x86_64.tar.bz2"

mkdir android-rebuilds
mkdir android-sdk
mkdir android-ndk
pushd android-rebuilds
for i in $(seq 1 5); do curl -O ${sdk_link} && unzip -qqo android-sdk_user.9.0.0_r21_linux-x86.zip -d ../android-sdk && rm -f android-sdk_user.9.0.0_r21_linux-x86.zip && s=0 && break || s=$? && sleep 15; done; (exit $s)
for i in $(seq 1 5); do curl -O ${sdk_tools_link} && unzip -qqo sdk-repo-linux-tools-26.1.1.zip -d ../android-sdk/android-sdk_user.9.0.0_r21_linux-x86 && rm -f sdk-repo-linux-tools-26.1.1.zip && s=0 && break || s=$? && sleep 15; done; (exit $s)
for i in $(seq 1 5); do curl -O ${ndk_link} && tar xjf android-ndk-r20b-linux-x86_64.tar.bz2 -C ../android-ndk && rm -f android-ndk-r20b-linux-x86_64.tar.bz2 && s=0 && break || s=$? && sleep 15; done; (exit $s)
popd
# Move ndk files into place
cp -a "temp/${gn_file}" android-ndk/android-ndk-r20b
cp -ar "temp/linux-x86_64" android-ndk/android-ndk-r20b/toolchains/llvm/prebuilt
rm -rf "temp"


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
## Extra fixes for Chromium source
python3 ungoogled-chromium/utils/patches.py apply src patches
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
/usr/bin/ninja -C out gn
popd


## Configure output folder
pushd src
mkdir -p out/Default
cat ../ungoogled-chromium/flags.gn ../android_flags.gn ../android_flags.release.gn > out/Default/args.gn
printf '\ntarget_cpu="'"$ARCH"'"' >> out/Default/args.gn
tools/gn/out/gn gen out/Default --fail-on-unused-args
popd


## Set compiler flags
export AR=${AR:=llvm-ar}
export NM=${NM:=llvm-nm}
export CC=${CC:=clang}
export CXX=${CXX:=clang++}

# Patch build/android/gyp/javac.py
patch -p1 --ignore-whitespace -i patches/ignore-aidl-assertion-error.patch --no-backup-if-mismatch

## Build
pushd src
/usr/bin/ninja -C out/Default $TARGET
popd
