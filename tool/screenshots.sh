#!/usr/bin/env bash
# Runs integration_test/app_flow_test.dart on the store screenshot devices and
# saves PNGs to build/screenshots/<device>/.
#
#   tool/screenshots.sh            # iOS 6.9", iOS 6.5" and Android phone
#   tool/screenshots.sh ios        # only the iPhones
#   tool/screenshots.sh android    # only the Android emulator
set -euo pipefail
cd "$(dirname "$0")/.."

only="${1:-all}"
avd="Adhaan_Screenshots"
package="in.codesaif.adhaan"

drive() { # <device id> <output dir> [extra flutter drive args...]
  local device="$1" out="$2"
  shift 2
  SCREENSHOT_DIR="build/screenshots/$out" flutter drive \
    --driver test_driver/integration_test.dart \
    --target integration_test/app_flow_test.dart \
    -d "$device" "$@"
}

simulator() { # <device type name> -> prints the booted simulator's UDID
  # Use the newest installed iOS runtime that supports the device type,
  # creating a simulator for it if there isn't one yet.
  local runtime udid
  runtime=$(xcrun simctl list runtimes -j | python3 -I -c '
import json, sys
name = sys.argv[1]
ios = [r for r in json.load(sys.stdin)["runtimes"]
       if r["platform"] == "iOS" and r["isAvailable"]
       and any(d["name"] == name for d in r["supportedDeviceTypes"])]
if ios:
    print(max(ios, key=lambda r: [int(p) for p in r["version"].split(".")])["identifier"])' "$1")
  [[ -n "$runtime" ]] || { echo "No iOS runtime supports $1" >&2; return 1; }
  udid=$(xcrun simctl list devices -j | python3 -I -c '
import json, sys
name, runtime = sys.argv[1], sys.argv[2]
for d in json.load(sys.stdin)["devices"].get(runtime, []):
    if d["name"] == name and d["isAvailable"]:
        print(d["udid"]); break' "$1" "$runtime")
  [[ -n "$udid" ]] || udid=$(xcrun simctl create "$1" "$1" "$runtime")
  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" -b >/dev/null
  echo "$udid"
}

if [[ "$only" == all || "$only" == ios ]]; then
  udid=$(simulator "iPhone 17 Pro Max") # 6.9": 1320 x 2868
  drive "$udid" ios-6.9
  udid=$(simulator "iPhone 11 Pro Max") # 6.5": 1242 x 2688
  drive "$udid" ios-6.5
fi

if [[ "$only" == all || "$only" == android ]]; then
  if ! emulator -list-avds | grep -qx "$avd"; then
    echo no | avdmanager create avd -n "$avd" -d pixel_2 \
      -k "system-images;android-VanillaIceCream;google_apis_playstore;arm64-v8a"
  fi
  serial=$(adb devices | awk '/^emulator-/{print $1; exit}')
  if [[ -z "$serial" ]]; then
    emulator -avd "$avd" -no-window -no-audio -no-boot-anim >/dev/null 2>&1 &
    adb wait-for-device
    serial=$(adb devices | awk '/^emulator-/{print $1; exit}')
  fi
  until [[ "$(adb -s "$serial" shell getprop sys.boot_completed | tr -d '\r')" == 1 ]]; do sleep 2; done

  # Install once so POST_NOTIFICATIONS can be granted before the test runs;
  # flutter drive reinstalls with -r, which keeps the grant.
  flutter build apk --debug
  adb -s "$serial" install -r build/app/outputs/flutter-apk/app-debug.apk
  adb -s "$serial" shell pm grant "$package" android.permission.POST_NOTIFICATIONS
  # The emulator's Play services geocoder crashes, so start with the city
  # already saved; city search is covered by the iOS runs.
  drive "$serial" android-phone --dart-define=SEED_PLACE=true
fi

echo "Screenshots:"
find build/screenshots -name '*.png' | sort
