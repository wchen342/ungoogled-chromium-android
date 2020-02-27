# 80.0.3987.122-1
* This is an important security release that fix three vulnerabilities. All previous versions should update as soon as possible.
  * [1044570] High: Integer overflow in ICU. Reported by André Bargull (with thanks to Jeff Walden from Mozilla) on 2020-01-22
  * [1045931] High CVE-2020-6407: Out of bounds memory access in streams. Reported by Sergei Glazunov of Google Project Zero on 2020-01-27
  * [1053604] High CVE-2020-6418: Type confusion in V8. Reported by Clement Lecigne of Google's Threat Analysis Group on 2020-02-18 (_actively exploited in the wild_)
* Fix video crash on Android P on certain machines

# 80.0.3987.106-1
* Port some privacy related functionality from `Bromite`, including:
  * flag to disable WebGL
  * flag to disable motion sensors
  * exit button and do not persist option
  * use blank page as homepage
  * setting for DNS-over-HTTPS (DoH)
  * flag to disable pull-to-refresh
* Disable contextual search in native code instead of Java
* Disable lite mode prompt
* Disable download articles over Wi-fi
* Build time change (not affecting users):
  * Exclude unit tests from domain substitution
  * Using system JDK instead of bundled one. Requires both Java-8 and Java-10 on Arch Linux.
  * Now build with SDK 29

# 79.0.3945.117-2
* Add ChromePublic target (API 19)
* Fix build failure for safe browsing
* Update `README`

# 79.0.3945.117-1
* Update NDK to r20b
* Remove split installer dependencies (Google Play), disable DFM
* Other source fixes
* Known issue: ~~some pages, including `chrome://flags`, `chrome://gpu` are not working~~ (Fixed)

# 78.0.3904.97-1
* Update scripts and patches to new version
* Merge patches from Bromite and Unobtainium
* New dependencies: nodejs binaries, lib files from ndk

# 77.0.3865.90-1
* Update patches to new version
* Update GN to latest commit
* Minor fixes

# 76.0.3809.132-1
* No change

# 76.0.3809.100-1
* Change default setting of contextual search to false

# 76.0.3809.87-1
* Add WebView builds
* Since `aapt` no longer works, bundled `aapt2` will be used until a rebuild of SDK 29 exists
* Minor bug fixes

# 75.0.3770.142-2
* Remove all Google Play related libraries
* Uncheck "Send statistics" on first run

# 75.0.3770.142-1
* Fix [#3](https://github.com/wchen342/ungoogled-chromium-android/issues/3)
* Disable resource obfuscation
* Add arm build

# 75.0.3770.100-1
* Change package name to avoid conflict with chromium

# 75.0.3770.80-1
* Reduce downloaded dependencies on gclient sync
* Prune more binaries
* Build gcm-client, eu-strip, closure-compiler from source; change error-prone to Maven version
* Domain substitution on all non-binary files

# 74.0.3729.169-1
* First release
