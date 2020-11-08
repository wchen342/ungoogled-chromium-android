#!/bin/bash
# Modified from Vanadium

set -o errexit -o nounset -o pipefail

KEYSTORE=$PWD/../../uc_keystore/uc-release-key.keystore
KEYSTORE_PASS=$PWD/../../uc_keystore/keystore_pass
APKSIGNER=$PWD/third_party/android_sdk/public/build-tools/30.0.1/apksigner
BUNDLETOOL=$PWD/build/android/gyp/bundletool.py
AAPT2=$PWD/third_party/android_build_tools/aapt2/aapt2

chrome_modern_target=chrome_modern_public_bundle
trichrome_chrome_bundle_target=trichrome_chrome_bundle
trichrome_chrome_apk_target=trichrome_library_apk
webview_target=system_webview_apk

# Argument parser from https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash/29754866#29754866
# -allow a command to fail with !’s side effect on errexit
# -use return value from ${PIPESTATUS[0]}, because ! hosed $?
! getopt --test > /dev/null 
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo 'I’m sorry, `getopt --test` failed in this environment.'
    exit 1
fi

OPTIONS=o:t:
LONGOPTS=output:,target:

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

if [[ "$TARGET" != "$chrome_modern_target" ]] && [[ "$TARGET" != "$trichrome_chrome_bundle_target" ]]; then
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
        ;;
    "$trichrome_chrome_bundle_target")
        FILENAME="TrichromeChrome"
        ;;
    *)
        echo "Filename parsing error"
        exit 3
        ;;
esac

echo "output: $OUTPUT, target: $TARGET, filename: $FILENAME"

cd $OUTPUT/apks

rm -rf release
mkdir release
cd release

$BUNDLETOOL build-apks --aapt2 $AAPT2 --bundle ../"$FILENAME".aab --output "$FILENAME".apks --mode=universal --ks $KEYSTORE --ks-pass file:$KEYSTORE_PASS --ks-key-alias uc
unzip "$FILENAME".apks universal.apk
mv universal.apk "$FILENAME".apk

if [[ "$TARGET" == "$trichrome_chrome_bundle_target" ]]; then
    for app in TrichromeLibrary TrichromeWebView; do
        if [ -f ../${app}.apk ]; then
            $APKSIGNER sign --ks $KEYSTORE --ks-pass file:$KEYSTORE_PASS --ks-key-alias uc_release --in ../${app}.apk --out $app.apk
        fi
    done
fi
