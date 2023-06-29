# Qt 6 Skeleton

A skeleton project for Qt 6 which supports linux/windows/macos/android/ios/web

In Makefile change project variables to whatever you want.

# Linux

Run `make dev-install` to configure dependencies
Run `make linux` to build the linux application
Run `make run-linux` to run the linux application
Run `make wasm` to build the wasm application
Run `make run-wasm` to run the wasm application
Run `make android` to build the android application
Run `make run-android` to run the android application on a connected android device. note the device must be debug enabled.
Run `make dist` to package linux/wasm/android in the dist dir

# Windows
[Qt installer](https://download.qt.io/official_releases/online_installers/qt-unified-windows-x64-online.exe)

# MacOs
[Qt installer](https://download.qt.io/official_releases/online_installers/qt-unified-mac-x64-online.dmg)

# TODOS
A github action is desired to automate the setup and build process.
Alternatively use docker for building. When using a github action it will need to install various tools which will take a lot time each time a build is performed. Creating a docker image where all tools are already installed might give a lot of speedup.
