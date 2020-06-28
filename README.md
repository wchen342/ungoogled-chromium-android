# ungoogled-chromium-android

Please see [CHANGELOG](CHANGELOG.md) for newest updates.

*A lightweight approach to removing Google web service dependency*

*Note: this is an **Android** build.*

**ungoogled-chromium is Google Chromium**, sans dependency on Google web services. It also features some tweaks to enhance privacy, control, and transparency *(almost all of which require manual activation or enabling)*.

**ungoogled-chromium retains the default Chromium experience as closely as possible**. Unlike other Chromium forks that have their own visions of a web browser, ungoogled-chromium is essentially a drop-in replacement for Chromium.

For more information on `ungoogled-chromium`, please visit the original repo: [Eloston/ungoogled-chromium](https://github.com/Eloston/ungoogled-chromium).

## Content Overview

* [Differences from ungoogled-chromium](#differences-from-ungoogled-chromium)
* [Limitations](#limitations)
* [Platforms and Versions](#platforms-and-versions)
* [Building Instructions](#building-instructions)
* [Reporting and Contributing](#reporting-and-contributing)
* [Extensions](#extensions)
* [F-droid Repository](#f-droid-repository)
* [TODO List](#todo-list)
* [Credits](#credits)
* [Related Projects](#related-projects)
* [License](#license)

## Differences from ungoogled-chromium

*These are the differences between a Linux build of ungoogled-chromium and this Android build.*

* Android specific patches and fixes are applied.
* Default configuration builds for `arm64` instead of `x64`.

## Limitations

The enhancements included in ungoogled-chromium **are not to be considered useful for journalists, people living in countries with freedom limitations, and those who are facing government-level adversaries**. Please look at tools specifically developed for these purposes, for example [Tor Browser](https://www.torproject.org/download/) in such cases.

## Platforms and Versions

Pre-built apks are named as `{BUILD_TARGET}_{CPU_ARCH}.apk`, where:
* `{BUILD_TARGET}` is one of `ChromePublic`, `MonoChromePublic`, `SystemWebview`.
  * `ChromePublic` is for API > 19 (Android 4.4) and only contains the browser.
  * `MonoChromePublic` is for API > 24 (Android 7.0) and contains both the browser and the webview.
  * `SystemWebview` is for API 21 - 23 (Android 5.0 - 6.0) and only contains the webview.
* `{CPU_ARCH}` is one of `x86`, `arm` (armeabi-v7a), `arm64` (arm64-v8a).
* Please also read this [important note](https://chromium.googlesource.com/chromium/src/+/HEAD/android_webview/docs/build-instructions.md#Important-notes-for-N_P) about Webview on Android N-P.
* The [Bromite Wiki](https://github.com/bromite/bromite/wiki/Installing-SystemWebView) can also be helpful.

## Building Instructions
*This build is built from Sylvain Beucler's [libre Android rebuilds](https://android-rebuilds.beuc.net/) instead of SDK/NDK binaries from Google.*

* Clone this repository
* ~~If you want to enable proprietary codecs (h264, mp3, mp4, etc.), add `proprietary_codecs=true` to the end of `android_flags.gn`.~~ It is now the default, since `proprietary_codecs` does not add the actual codecs, only codes to handle those file types.
* enter repo directory and run `./build.sh`.

Build time dependencies can be roughly referred from [AUR](https://aur.archlinux.org/packages/ungoogled-chromium/).

For a more customized building process, see building instructions from [the original repo](https://github.com/Eloston/ungoogled-chromium/blob/master/docs/building.md).

## Reporting and Contributing

* For reporting issues and contacting, see [SUPPORT](SUPPORT.md)
* This project is still in its early stage, so contributions are welcomed.

## Extensions

*Note: the Extension-support version is highly experimental and unstable. Only use it if you want to help testing, or you know what you are doing! I will not be responsible for any loss or damage caused.*

The extensions are likely not fully functional yet.

There are three methods to install extensions:
 - Method 1 (the easiest way):
   1. Go to `chrome://flags/` and change `#extension-mime-request-handling` to `Always prompt for install` and relaunch your browser.
   2. Go to chrome webstore page
   3. Switch to desktop site
   4. Search for the extension you want to install and click `Add to Chromium`
   5. The browser should prompt for installation after finishing downloading
   6. Check `chrome://extensions/` and you should see the extension there.
 - Method 2 (Direct Download):
   1. Go to `chrome://flags/` and change `#extension-mime-request-handling` to `Always prompt for install` and relaunch your browser.
   2. Get direct link to `crx` file following the instructions [here](https://ungoogled-software.github.io/ungoogled-chromium-wiki/faq#downloading-the-crx-file).
   3. Paste the link into omnibox and go to that link.
   4. The browser should prompt for installation after finishing downloading
   5. Check `chrome://extensions/` and you should see the extension there.
 - Method 3 (Developer Mode Folder Loading. This method only supports `Android 5.1+`):
   1. Download extension following the instructions [here](https://ungoogled-software.github.io/ungoogled-chromium-wiki/faq#downloading-the-crx-file).
   2. Extract the `crx` file into a folder with`unzip`/`7z` and copy the folder to your device.
   3. Notice for Android 10: as a workaround for a [permission issue](https://github.com/wchen342/ungoogled-chromium-android/issues/27), you need to enable "Allow from unknown source" for `Ungoogled Chromium Extensions".
   4. Make sure you also give storage access.
   5. Open `chrome://extensions/` and enable Developer mode, refresh.
   6. Click `Load unpacked` and select the folder you copied. Notice that Android has two file selections, one for selecting files and one for selecting folders. Make sure you use the right one.
   7. Refresh and you shall see the extension in the list.

## F-droid Repository

I have set up an experimental f-droid repository. Because of the limitation of its server tools, only the `arm` version is hosted.

You can use f-Droid client and add [this repository](https://www.droidware.info/fdroid/repo?fingerprint=2144449AB1DD270EC31B6087409B5D0EA39A75A9F290DA62AC1B238A0EAAF851).

## Credits

* [The Chromium Project](https://www.chromium.org/)
* [ungoogled-chromium](https://github.com/Eloston/ungoogled-chromium)
* [xsmile's fork](https://github.com/xsmile/ungoogled-chromium/tree/android)
* [Bromite](https://github.com/bromite/bromite)
* [Kiwi Browser](https://github.com/kiwibrowser)
* [dvalter's patches](https://github.com/dvalter/chromium-android-ext-dev)

## Related Projects

* [Bromite](https://github.com/bromite/bromite) (Another build for Android. Has some own features.)

## License

See [LICENSE](LICENSE.md)
