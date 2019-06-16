# ungoogled-chromium-android

*A lightweight approach to removing Google web service dependency*

*Note: this is an **Android** build. It is currently experimental.*

**ungoogled-chromium is Google Chromium**, sans dependency on Google web services. It also features some tweaks to enhance privacy, control, and transparency *(almost all of which require manual activation or enabling)*.

**ungoogled-chromium retains the default Chromium experience as closely as possible**. Unlike other Chromium forks that have their own visions of a web browser, ungoogled-chromium is essentially a drop-in replacement for Chromium.

For more information on `ungoogled-chromium`, please visit the original repo: [Eloston/ungoogled-chromium](https://github.com/Eloston/ungoogled-chromium).

## Differences from ungoogled-chromium

*These are the differences between a Linux build of ungoogled-chromium and this Android build.*

* Several binaries are not pruned due to build time error.
* Default configuration builds for `arm64` instead of `x64`.

## Supported Platforms and Distributions

The current build has been tested on:
* cpu_arch: `x86`, `arm64`
* OS: API 28 (Android 8.1), API 27 (Android 8.0), LineageOS 15.1

*This build requires a minimum API 24 (Nougat).*

## Building Instructions
*This build is built from Sylvain Beucler's [libre Android rebuilds](http://android-rebuilds.beuc.net/) instead of SDK/NDK binaries from Google.*

Clone this repository and run `build.sh`. Build time dependencies can be rougnly referred from [AUR](https://aur.archlinux.org/packages/ungoogled-chromium-archlinux/).

For a more customized building process, see building instructions from [the original repo](https://github.com/Eloston/ungoogled-chromium/blob/master/docs/building.md).

## TODO List
- [ ] Prune the binaries
- [ ] Remove dependencies on SDK tools and extras
- [ ] Remove Play Services dependencies
- [ ] Domain substitution in java files
- [ ] Java patches (mostly UI-related)

## Credits

* [The Chromium Project](//www.chromium.org/)
* [ungoogled-chromium](//github.com/Eloston/ungoogled-chromium)
* [xsmile's fork](//github.com/xsmile/ungoogled-chromium/tree/android)
* [Bromite](//github.com/bromite/bromite)

## Related Projects

* [Bromite](//github.com/bromite/bromite) (Another build for Android. Has some own features.)

## License

See [LICENSE](LICENSE)