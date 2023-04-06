# Qt 6 Skeleton

A skeleton project for Qt 6 which supports linux/windows/macos/android/ios/web

In Makefile change PROJECT_NAME to whatever you want.

# Linux

## Requirements
system packages
 - qmake6
 - qml6-module-qtqml-workerscript
 - qml6-module-qtquick
 - qml6-module-qtquick-window
 - qt6-base-dev
 - qt6-declarative-dev

## Building
run `make native`

## Running
The file build/native/PROJECT_NAME is the resulting binary.

## Packaging
TODO

# Windows

TODO

# MacOS

TODO

# Android

TODO

# IOS

TODO

# WASM

## Requirements
Install qt with wasm single threaded as target with the installer.
Set QMAKEWASM variable in Makefile to the install location.
Find out the version of emsdk to install by building for wasm.
Install emsdk as followed.
```
export EMSDK_BASE_LOCATION=~/packages
cd $EMSDK_BASE_LOCATION
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install 3.1.25
./emsdk activate 3.1.25
echo 'source "$EMSDK_BASE_LOCATION/emsdk/emsdk_env.sh"' >> $HOME/.bashrc
source "$EMSDK_BASE_LOCATION/emsdk/emsdk_env.sh"
```
Try building for wasm with the Makefile to find out which version is required.

## Building
Optionally supply a logo.svg for the splash screen.
Run `make wasm`.

## Running
Run `emrun build/wasm/PROJECT_NAME.html`.

## Deploying
The complete application consists of the files PROJECT_NAME.html/js/wasm, qtloader.js and logo.svg in build/wasm folder.

# TODOS
A github action is desired to automate the building.
	see https://github.com/marketplace/actions/install-qt for action to install qt.
		this needs some work because it doesn't support building wasm which is one of the end goes of this project
