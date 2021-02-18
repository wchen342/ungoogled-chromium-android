# ungoogled-chromium-android

Please see [CHANGELOG](CHANGELOG.md) for latest updates.

*A lightweight approach to removing Google web service dependency*

*Note: this is an **Android** build.*

**Help is welcome!**

For more information on `ungoogled-chromium`, please visit the original repo: [Eloston/ungoogled-chromium](https://github.com/Eloston/ungoogled-chromium).

## Content Overview

* [Objectives](#objectives)
* [Differences from ungoogled-chromium](#differences-from-ungoogled-chromium)
* [Limitations](#limitations)
* [Platforms and Versions](#platforms-and-versions)
* [Building Instructions](#building-instructions)
* [Reporting and Contributing](#reporting-and-contributing)
* [Extensions](#extensions)
* [F-droid Repository](#f-droid-repository)
* [Credits](#credits)
* [Related Projects](#related-projects)
* [Sponsors](#sponsors)
* [License](#license)

## Objectives

In descending order of significance (i.e. most important objective first):

1. **ungoogled-chromium is Google Chromium, sans dependency on Google web services**.
2. **ungoogled-chromium retains the default Chromium experience as closely as possible**. Unlike other Chromium forks that have their own visions of a web browser, ungoogled-chromium is essentially a drop-in replacement for Chromium.
3. **ungoogled-chromium features tweaks to enhance privacy, control, and transparency**. However, almost all of these features must be manually activated or enabled. For more details, see [Feature Overview](https://github.com/eloston/ungoogled-chromium#feature-overview).

## Differences from ungoogled-chromium

*These are the differences between a Linux build of ungoogled-chromium and ungoogled-chromium-android.*

* Disable Android specific functionalities:
   * lite mode
   * contextual search
   * prefetch
   * remove home page links
   * remove unnecessary account permissions
* Android specific enhancements:
   * Add `Startpage.com` and `Qwant.com` as search engine options
   * Add new folder button in bookmark manager
   * Add back flags to enable deprecated TLS warnings
   * Add back flags to enable process sharing
   * Add flag to enable update notifications (disabled by default and will only send a single `GET` request to my server periodically)
   * Add flags to always send `save-data` flag in header
   * Add flags to force tablet UI and desktop mode
* Borrowed from Bromite:
   * Exit menu item
   * flag to disable device orientation API
   * option to clear open tabs between sessions
   * prevent WebRTC address leaking
   * enable DNS-over-Https by default
   * Add bookmark import/export options
   * Disable DRM media preprovisioning which leaks connections
* All Google play and Google service related blobs are removed. This includes Firebase, GCM (Google Cloud Messaging), GMS (Google Mobile Services) and bridge to Google Play. 
* Releases are built for `arm`, `arm64` and `x86`. There is no `x86_64` build.

## Limitations

The enhancements included in ungoogled-chromium **are not to be considered useful for journalists, people living in countries with freedom limitations, and those who are facing government-level adversaries**. Please look at tools specifically developed for these purposes, for example [Tor Browser](https://www.torproject.org/download/) in such cases.

## Platforms and Versions

Pre-built apks are named as `{BUILD_TARGET}_{CPU_ARCH}.apk`, where:
* `{BUILD_TARGET}` is one of `ChromeModernPublic`, `Trichrome`, `SystemWebview`.
  * `ChromeModernPublic` is for API >= 21 (Android 5.0) and only contains the browser.
  * `Trichrome` is for API >= 29 (Android 10) and only contains the browser. *Note: `Trichrome` has two apks, you need to install both for ungoogled-chromium to work.*
  * `SystemWebview` is for >= API 21 (Android 5.0) and only contains the webview.
* `{CPU_ARCH}` is one of `x86`, `arm` (armeabi-v7a), `arm64` (arm64-v8a).
* Please also read this [important note](https://chromium.googlesource.com/chromium/src/+/HEAD/android_webview/docs/build-instructions.md#Important-notes-for-N_P) about Webview on Android N-P.
* The [Bromite Wiki](https://github.com/bromite/bromite/wiki/Installing-SystemWebView) can also be helpful.

## Building Instructions
*This build is built from Sylvain Beucler's [libre Android rebuilds](https://android-rebuilds.beuc.net/) instead of SDK/NDK binaries from Google.*

* Clone this repository
* Make sure you have enough disk space and memory to build chromium
* enter repo directory and run `./build.sh`.

Build time dependencies (*package names as in Fedora 33. Other distributions may have different package names*):

<details>
  <summary>required packages</summary>
  
  ```
      bison
      bzip2
      clang
      curl
      dbus-devel
      expat-devel
      fakeroot-libs.i686
      flex
      git
      glib2
      glib2-devel
      glibc.i686
      glibc-devel.i686
      gnupg2
      gperf
      java-1.8.0-openjdk-devel
      java-1.8.0-openjdk-headless
      java-11-openjdk
      java-11-openjdk-devel
      java-11-openjdk-headless
      krb5-devel
      libatomic-static
      libdrm-devel
      libgcc.i686
      libstdc++-static
      libtool-ltdl.i686
      libtool-ltdl-devel.i686
      libuuid-devel
      libxkbcommon-devel
      lld
      llvm
      make
      maven
      ninja-build
      nodejs
      npm
      nss-devel
      passwd
      patch
      perl
      protobuf
      python2.7
      python3
      rsync
      tar
      unzip
      yasm
      wget
  ```
</details>

In addition, scripts need to be run under python2. `virtualenv` or `conda` can be used to set up such an environment.

For a more customized building process, see building instructions from [the original repo](https://github.com/Eloston/ungoogled-chromium/blob/master/docs/building.md).

## Reporting and Contributing

* For reporting issues and contacting, see [SUPPORT](SUPPORT.md)
* This project is still in its early stage, so contributions are welcomed.

## Extensions

*Note: the extension-support version is experimental. It is not officially a part of `ungoogled-chromium`. Only use it if you want to help testing, or you know what you are doing! I will not be responsible for any loss or damage caused.*

The extension-support version is *NOT* a successor of Kiwi browser.

Some common extensions are known to work. Please report what extensions are working or not in discussions.

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
      1. Optionally, you can use a third-party website to download the `crx` file. However, do so at your own risk, as I will take *absolutely no* responsibility for problems caused by using a third party website or service.
   3. Paste the link into omnibox and go to that link.
   4. The browser should prompt for installation after finishing downloading
   5. Check `chrome://extensions/` and you should see the extension there.
 - Method 3 (Developer Mode Folder Loading. This method only supports Android 5.1 to 10):
   1. Download extension following the instructions [here](https://ungoogled-software.github.io/ungoogled-chromium-wiki/faq#downloading-the-crx-file).
      1. Optionally, you can use a third-party website to download the `crx` file. However, do so at your own risk, as I will take *absolutely no* responsibility for problems caused by using a third party website or service.
   2. Extract the `crx` file into a folder with`unzip`/`7z` and copy the folder to your device.
      1. For an alternative way to extract the crx` file on device, see [this comment](https://github.com/ungoogled-software/ungoogled-chromium-android/issues/49#issuecomment-767683754).
   3. **Notice for Android 10**: as a workaround for a [permission issue](https://github.com/wchen342/ungoogled-chromium-android/issues/27), you need to enable "Allow from unknown source" for "Ungoogled Chromium Extensions".
   4. **Make sure you also give storage access**.
   5. Open `chrome://extensions/` and enable Developer mode.
   6. Click `Load unpacked` and select the folder you copied. Notice that Android has two file selections, one for selecting files and one for selecting folders. Make sure you use the right one.
   7. Refresh and you shall see the extension in the list.

## F-Droid Repository

I have set up a F-Droid repository. Because of the limitation of its server tools, the binaries are compiled towards `arm`. They are compatible on 64-bit `arm64` devices too.

You can use F-Droid client and add [this repository](https://www.droidware.info/fdroid/repo?fingerprint=2144449AB1DD270EC31B6087409B5D0EA39A75A9F290DA62AC1B238A0EAAF851).

## Credits

* [The Chromium Project](https://www.chromium.org/)
* [ungoogled-chromium](https://github.com/Eloston/ungoogled-chromium)
* [xsmile's fork](https://github.com/xsmile/ungoogled-chromium/tree/android)
* [Bromite](https://github.com/bromite/bromite)
* [Kiwi Browser](https://github.com/kiwibrowser)
* [dvalter's patches](https://github.com/dvalter/chromium-android-ext-dev)

## Related Projects

* [Bromite](https://github.com/bromite/bromite) (Another build for Android. Has some own features.)

## Sponsors

* Thanks to [Gandi.net](https://www.gandi.net/) for kindly providing us with building servers.

## License

See [LICENSE](LICENSE.md).

`ungoogled-chromium-android` is part of `ungoogled-chromium`. Everything published here, including (but not limited to) patches, scripts and other files are licensed under GPLv3+.
