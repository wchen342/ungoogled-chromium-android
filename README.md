# ungoogled-chromium-android

Please see [CHANGELOG](https://github.com/wchen342/ungoogled-chromium-android/blob/master/CHANGELOG.md) for newest updates.

*A lightweight approach to removing Google web service dependency*

*Note: this is an **Android** build. It is currently experimental.*

**ungoogled-chromium is Google Chromium**, sans dependency on Google web services. It also features some tweaks to enhance privacy, control, and transparency *(almost all of which require manual activation or enabling)*.

**ungoogled-chromium retains the default Chromium experience as closely as possible**. Unlike other Chromium forks that have their own visions of a web browser, ungoogled-chromium is essentially a drop-in replacement for Chromium.

For more information on `ungoogled-chromium`, please visit the original repo: [Eloston/ungoogled-chromium](https://github.com/Eloston/ungoogled-chromium).

## Content Overview

* [Differences from ungoogled-chromium](#differences-from-ungoogled-chromium)
* [Platforms and Versions](#platforms-and-versions)
* [Building Instructions](#building-instructions)
* [Reporting and Contributing](#reporting-and-contributing)
* [F-droid Repository](#f-droid-repository)
* [TODO List](#todo-list)
* [Credits](#credits)
* [Related Projects](#related-projects)
* [License](#license)

## Differences from ungoogled-chromium

*These are the differences between a Linux build of ungoogled-chromium and this Android build.*

* Android specific patches and fixes are applied.
* Default configuration builds for `arm64` instead of `x64`.

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

* For reporting and contacting, see [SUPPORT.md](SUPPORT.md)
* This project is still in its early stage, so contributions are welcomed. Currently, the major task is to remove proprietary Google dependencies.

## F-droid Repository

I have set up an experimental f-droid repository. Because of the limitation of its server tools, only arm64 version is hosted.

You can use f-Droid client and add [this repository](https://www.droidware.info/fdroid/repo).


## TODO List
- [x] Remove dependencies on SDK tools and extras
- [x] Domain substitution in java files
- [x] Prune binaries (*Note: haven't found a way to build desugar-runtime.jar without bazel. Please let me know if you know how.*)
- [x] Remove Play Services
- [ ] Java patches

## Credits

* [The Chromium Project](//www.chromium.org/)
* [ungoogled-chromium](//github.com/Eloston/ungoogled-chromium)
* [xsmile's fork](//github.com/xsmile/ungoogled-chromium/tree/android)
* [Bromite](//github.com/bromite/bromite)

## Related Projects

* [Bromite](//github.com/bromite/bromite) (Another build for Android. Has some own features.)

## License

See [LICENSE](LICENSE)
