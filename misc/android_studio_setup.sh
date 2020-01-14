#!/usr/bin/env bash
set -eux -o pipefail

chromium_version=79.0.3945.117
chrome_target=chrome_public_apk
monochrome_target=monochrome_public_apk
webview_target=system_webview_apk

# Create symbol links to gn, depot-tools
pushd src
pushd buildtools/linux64
ln -s ../../tools/gn/out/gn
popd

pushd third_party
ln -s ../../depot_tools
popd
popd

## Set compiler flags
export AR=${AR:=llvm-ar}
export NM=${NM:=llvm-nm}
export CC=${CC:=clang}
export CXX=${CXX:=clang++}

## Genarate gn file
pushd src/tools/gn
build/gen.py
/usr/bin/ninja -C out gn
popd

# Need different GN flags than a release build
pushd src
output_folder=out/Debug_apk
mkdir -p ${output_folder}
cat ../android_flags.debug.gn ../android_flags.gn > ${output_folder}/args.gn

# Run gn first
tools/gn/out/gn gen ${output_folder} --fail-on-unused-args

# Compile apk
/usr/bin/ninja -C ${output_folder} ${monochrome_target}
popd

###
# Develop folder
pushd src
output_folder=out/Debug
mkdir -p ${output_folder}
cat ../android_flags.debug.gn ../android_flags.gn > ${output_folder}/args.gn

# Run gn first
tools/gn/out/gn gen ${output_folder} --fail-on-unused-args

# Generate gradle files
# patch generate_gradle.py to use system ninja instead of depot_tools
pushd ..
patch -p1 --ignore-whitespace -i patches/generate_gradle.patch --no-backup-if-mismatch
popd
python build/android/gradle/generate_gradle.py --target //chrome/android:${monochrome_target} --output-directory ${output_folder}
popd
