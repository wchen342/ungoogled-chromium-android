#!/bin/bash
# Modified from Vanadium

set -o errexit -o nounset -o pipefail

KEYSTORE=$PWD/../../keystore/ungoogled-chromium-release-key-1.keystore
KEYSTORE_PASS=$PWD/../../keystore/keystore_pass
APKSIGNER=$PWD/third_party/android_sdk/public/build-tools/29.0.2/apksigner
BUNDLETOOL=$PWD/build/android/gyp/bundletool.py
AAPT2=$PWD/third_party/android_build_tools/aapt2/aapt2

cd out/Default/apks

rm -rf release
mkdir release
cd release

$BUNDLETOOL build-apks --aapt2 $AAPT2 --bundle ../TrichromeChrome.aab --output TrichromeChrome.apks --mode=universal --ks $KEYSTORE --ks-pass file:$KEYSTORE_PASS --ks-key-alias uc_release
unzip TrichromeChrome.apks universal.apk
mv universal.apk TrichromeChrome.apk

for app in TrichromeLibrary TrichromeWebView; do
    if [ -f ../${app}.apk ]; then
        $APKSIGNER sign --ks $KEYSTORE --ks-pass file:$KEYSTORE_PASS --ks-key-alias uc_release --in ../${app}.apk --out $app.apk
    fi
done
