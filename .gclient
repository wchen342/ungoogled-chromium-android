solutions = [
  {
    "url": "https://chromium.googlesource.com/chromium/src.git",
    "managed": False,
    "name": "src",
    "custom_deps": {
        "src/chrome/browser/resources/media_router/extension/src": None,
        "src/chrome/test/data/perf/canvas_bench": None,
        "src/chrome/test/data/perf/frame_rate/content": None,
        "src/chrome/test/data/xr/webvr_info": None,
        "src/chrome/test/data/xr/webxr_samples": None,
        "src/media/cdm/api": None,
        "src/third_party/arcore-android-sdk/src": None,
        "src/third_party/depot_tools": None,
        "src/third_party/feed/src": None,
        "src/third_party/shaderc/src": None,
        "src/third_party/SPIRV-Tools/src": None,
        "src/third_party/swiftshader": None,
        "src/third_party/ub-uiautomator/lib": None,
        "src/third_party/visualmetrics/src": None,
        "src/third_party/webdriver/pylib": None,
        "src/third_party/webgl/src": None,
        "src/third_party/webrtc": None,
        "src/third_party/yasm/source/patched-yasm": None,
        "src/tools/gyp": None,
        "src/tools/luci-go": None,
        "src/tools/page_cycler/acid3": None,
        "src/tools/swarming_client": None,
    },
    "custom_vars": {
        "checkout_nacl": False,
    },
  },
]
target_os = ["android"]
target_os_only = "true"

