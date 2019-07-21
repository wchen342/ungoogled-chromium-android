#!/usr/bin/env bash
set -eux -o pipefail

chromium_version=75.0.3770.142
target=monochrome_public_apk

# Create symbol links to gn, depot-tools
cd src
pushd buildtools/linux64
ln -s ../../tools/gn/out/gn
popd

pushd third_party
ln -s ../../depot_tools
popd

# Need different GN flags than a release build
mkdir -p out/Debug
cp -a ../android_flags.debug.gn out/Debug/args.gn

# Run gn first
tools/gn/out/gn gen out/Debug --fail-on-unused-args

## Set compiler flags
export AR=${AR:=llvm-ar}
export NM=${NM:=llvm-nm}
export CC=${CC:=clang}
export CXX=${CXX:=clang++}

# Compile apk
ninja -C out/Debug ${target}

# Generate gradle files
python build/android/gradle/generate_gradle.py --target //chrome/android:${target} --output-directory out/Debug
