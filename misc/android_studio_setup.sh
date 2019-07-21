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

mkdir -p out/Debug
cat ../ungoogled-chromium/flags.gn ../android_flags.gn > out/Debug/args.gn

python build/android/gradle/generate_gradle.py --target //chrome/android:${target} --output-directory out/Debug -j 40
