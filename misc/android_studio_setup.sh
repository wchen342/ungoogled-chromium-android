#!/usr/bin/env bash
set -eux -o pipefail

chromium_version=76.0.3809.87
target=monochrome_public_apk

# Create symbol links to gn, depot-tools
cd src
pushd buildtools/linux64
ln -s ../../tools/gn/out/gn
popd

pushd third_party
ln -s ../../depot_tools
popd

## Set compiler flags
export AR=${AR:=llvm-ar}
export NM=${NM:=llvm-nm}
export CC=${CC:=clang}
export CXX=${CXX:=clang++}

# Need different GN flags than a release build
output_folder=out/Debug_apk
mkdir -p ${output_folder}
cat ../android_flags.debug.gn ../android_flags.gn > ${output_folder}/args.gn

# Run gn first
tools/gn/out/gn gen ${output_folder} --fail-on-unused-args

# Compile apk
ninja -C ${output_folder} ${target}

###
# Develop folder
output_folder=out/Debug
mkdir -p ${output_folder}
cat ../android_flags.debug.gn ../android_flags.gn > ${output_folder}/args.gn

# Run gn first
tools/gn/out/gn gen ${output_folder} --fail-on-unused-args

# Generate gradle files
python build/android/gradle/generate_gradle.py --target //chrome/android:${target} --output-directory ${output_folder}
