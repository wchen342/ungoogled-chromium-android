# 74.0.3729.169-1
* First release

# 75.0.3770.80-1
* Reduce downloaded dependencies on gclient sync
* Prune more binaries
* Build gcm-client, eu-strip, closure-compiler from source; change error-prone to Maven version
* Domain substitution on all non-binary files

# 75.0.3770.100-1
* Change package name to avoid conflict with chromium

# 75.0.3770.142-1
* Fix [#3](https://github.com/wchen342/ungoogled-chromium-android/issues/3)
* Disable resource obfuscation
* Add arm build

# 75.0.3770.142-2
* Remove all Google Play related libraries
* Uncheck "Send statistics" on first run

# 76.0.3809.87-1
* Add WebView builds
* Since `aapt` no longer works, bundled `aapt2` will be used until a rebuild of SDK 29 exists
* Minor bug fixes

# 76.0.3809.100-1
* Change default setting of contextual search to false

# 76.0.3809.132-1
* No change

# 77.0.3865.90-1
* Update patches to new version
* Update GN to latest commit
* Minor fixes

# 78.0.3904.97-1
* Update scripts and patches to new version
* Merge patches from Bromite and Unobtainium
* New dependencies: nodejs binaries, lib files from ndk

# 79.0.3945.117-1
* Update NDK to r20b
* Remove split installer dependencies (Google Play), disable DFM
* Other source fixes
* Known issue: ~~some pages, including `chrome://flags`, `chrome://gpu` are not working~~ (Fixed)