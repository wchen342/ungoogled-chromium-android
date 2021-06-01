#!/bin/bash
# Modified from Vanadium

set -o errexit -o nounset -o pipefail

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "${SCRIPT_PATH}/.build_config"

KEYSTORE=$PWD/../../uc_keystore/uc-release-key.keystore
KEYSTORE_PASS=$PWD/../../uc_keystore/keystore_pass
APKSIGNER=$PWD/third_party/android_sdk/public/build-tools/30.0.1/apksigner
BUNDLETOOL=$PWD/build/android/gyp/bundletool.py
AAPT2=$PWD/third_party/android_build_tools/aapt2/aapt2

# Argument parser from https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash/29754866#29754866
# -allow a command to fail with !’s side effect on errexit
# -use return value from ${PIPESTATUS[0]}, because ! hosed $?
! getopt --test > /dev/null 
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo 'I’m sorry, `getopt --test` failed in this environment.'
    exit 1
fi

OPTIONS=o:a:t:
LONGOPTS=output:,arch:,target:

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

OUTPUT=- TARGET=-

# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
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

if [[ "$TARGET" != "$chrome_modern_target" ]] && [[ "$TARGET" != "$trichrome_chrome_bundle_target" ]] && [[ "$TARGET" != "$trichrome_chrome_64_bundle_target" ]] \
    && [[ "$TARGET" != "$trichrome_chrome_apk_target" ]] && [[ "$TARGET" != "$trichrome_webview_target" ]] && [[ "$TARGET" != "$trichrome_webview_64_target" ]]; then
    echo "Wrong target"
    exit 4
fi

if [[ ! -d $OUTPUT ]]; then
  echo "Output folder doesn't exist"
  exit 1
fi

case "$TARGET" in
    "$chrome_modern_target")
        FILENAME="ChromeModernPublic"
        FILENAME_OUT="ChromeModernPublic"
        ;;
    "$trichrome_chrome_bundle_target")
        FILENAME="TrichromeChrome"
        FILENAME_OUT="TrichromeChrome"
        ;;
    "$trichrome_chrome_64_bundle_target")
        FILENAME="TrichromeChrome64"
        FILENAME_OUT="TrichromeChrome"
        ;;
    "$trichrome_chrome_apk_target")
        FILENAME="TrichromeChrome"
        FILENAME_OUT="TrichromeChrome"
        ;;
    "$trichrome_webview_target")
        FILENAME="TrichromeWebView"
        FILENAME_OUT="TrichromeWebView"
        ;;
    "$trichrome_webview_64_target")
        FILENAME="TrichromeWebView64"
        FILENAME_OUT="TrichromeWebView"
        ;;
    *)
        echo "Filename parsing error"
        exit 3
        ;;
esac

echo "output: $OUTPUT, arch: $ARCH, target: $TARGET, filename: $FILENAME"

cd $OUTPUT/apks

rm -rf release
mkdir release
cd release

if [[ "$TARGET" != "$trichrome_webview_target" ]] && [[ "$TARGET" != "$trichrome_webview_64_target" ]] && [[ "$TARGET" != "$trichrome_chrome_apk_target" ]]; then
    $BUNDLETOOL build-apks --aapt2 $AAPT2 --bundle ../"$FILENAME".aab --output "$FILENAME".apks --mode=universal --ks $KEYSTORE --ks-pass file:$KEYSTORE_PASS --ks-key-alias uc
    unzip "$FILENAME".apks universal.apk
    mv universal.apk "${FILENAME_OUT}".apk
    $APKSIGNER sign --ks $KEYSTORE --ks-pass file:$KEYSTORE_PASS --ks-key-alias uc --in "${FILENAME_OUT}".apk --out "${FILENAME_OUT}".apk
fi

if [[ "$TARGET" == "$trichrome_chrome_bundle_target" ]] || [[ "$TARGET" == "$trichrome_webview_target" ]] || [[ "$TARGET" == "$trichrome_chrome_apk_target" ]]; then
    for app in TrichromeLibrary TrichromeWebView TrichromeChrome; do
        if [ -f "../${app}.apk" ]; then
            $APKSIGNER sign --ks $KEYSTORE --ks-pass file:$KEYSTORE_PASS --ks-key-alias uc --in "../${app}.apk" --out "${app}.apk"
        fi
    done
fi
if [[ "$TARGET" == "$trichrome_chrome_64_bundle_target" ]] || [[ "$TARGET" == "$trichrome_webview_64_target" ]]; then
    for app in TrichromeLibrary TrichromeWebView; do
        if [ -f "../${app}64.apk" ]; then
            $APKSIGNER sign --ks $KEYSTORE --ks-pass file:$KEYSTORE_PASS --ks-key-alias uc --in "../${app}64.apk" --out "${app}.apk"
        fi
    done
fi
