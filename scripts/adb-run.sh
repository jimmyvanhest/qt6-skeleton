#!/bin/bash
set -ex
cd "$(dirname "$0")"/..

${ANDROID_SDK_ROOT}/platform-tools/adb install $1
pkg=$(${ANDROID_SDK_ROOT}/build-tools/31.0.0/aapt dump badging $1|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
act=$(${ANDROID_SDK_ROOT}/build-tools/31.0.0/aapt dump badging $1|awk -F" " '/launchable-activity/ {print $2}'|awk -F"'" '/name=/ {print $2}')
${ANDROID_SDK_ROOT}/platform-tools/adb shell am start -n $pkg/$act
