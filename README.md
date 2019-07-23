# ungoogled-chromium-android

*A lightweight approach to removing Google web service dependency*

*Note: this is an **Android** build. It is currently experimental.*

**ungoogled-chromium is Google Chromium**, sans dependency on Google web services. It also features some tweaks to enhance privacy, control, and transparency *(almost all of which require manual activation or enabling)*.

**ungoogled-chromium retains the default Chromium experience as closely as possible**. Unlike other Chromium forks that have their own visions of a web browser, ungoogled-chromium is essentially a drop-in replacement for Chromium.

For more information on `ungoogled-chromium`, please visit the original repo: [Eloston/ungoogled-chromium](https://github.com/Eloston/ungoogled-chromium).

## Content Overview

* [Differences from ungoogled-chromium](#differences-from-ungoogled-chromium)
* [Supported Platforms](#supported-platforms)
* [Building Instructions](#building-instructions)
* [Reporting and Contributing](#reporting-and-contributing)
* [F-droid Repository](#f-droid-repository)
* [TODO List](#todo-list)
* [Credits](#credits)
* [Related Projects](#related-projects)
* [License](#license)

## Differences from ungoogled-chromium

*These are the differences between a Linux build of ungoogled-chromium and this Android build.*

* Current build still include proprietary libraries from Google. They are supposed to be removed in the future.
* Android specific fixes are applied.
* Default configuration builds for `arm64` instead of `x64`.

## Supported Platforms

The current build has been tested on:
* cpu_arch: `x86`, `arm`, `arm64`
* OS: API 28 (Android 8.1), API 27 (Android 8.0), LineageOS 16.0

Theoretically it will run on any device with a minimum API of 24 (Nougat).


## Building Instructions
*This build is built from Sylvain Beucler's [libre Android rebuilds](http://android-rebuilds.beuc.net/) instead of SDK/NDK binaries from Google.*

* Clone this repository
* If you want to enable proprietary codecs (h264, mp3, mp4, etc.), add `proprietary_codecs=true` to the end of `android_flags.gn`
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
- [x] Prune binaries (*Note: haven't found a way to build desugar-runtime without bazel. Please let me know if you know how.*)
- [ ] Remove Play Services [WIP]
  * GCM removed
- [ ] Java patches (low priority)

## Credits

* [The Chromium Project](//www.chromium.org/)
* [ungoogled-chromium](//github.com/Eloston/ungoogled-chromium)
* [xsmile's fork](//github.com/xsmile/ungoogled-chromium/tree/android)
* [Bromite](//github.com/bromite/bromite)

## Related Projects

* [Bromite](//github.com/bromite/bromite) (Another build for Android. Has some own features.)

## License

See [LICENSE](LICENSE)