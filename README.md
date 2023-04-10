# Qt 6 Skeleton

A skeleton project for Qt 6 which supports linux/windows/macos/android/ios/web

In Makefile change project variables to whatever you want.

# Linux

## Requirements
System packages
 - g++
 - qmake6
 - qml6-module-qtqml-workerscript
 - qml6-module-qtquick
 - qml6-module-qtquick-window
 - qt6-base-dev
 - qt6-declarative-dev

```
cd ~/packages
wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
wget https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage
chmod +x linuxdeploy*.AppImage
```

## Building
Run `make native`

## Running
The file build/native/PROJECT_NAME is the resulting binary.

## Packaging
Run `make dist`
This will create a debian package and an AppImage in dist/linux

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
for qt 6.5 emsdk version 3.1.25 is required
Install emsdk as followed.
```
cd $PACKAGEDIR
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install 3.1.25
./emsdk activate 3.1.25
```

## Building
Run `make wasm`.

## Running
Run `emrun build/wasm/PROJECT_NAME.html`.

## Deploying
Run `make dist`
This will put the required files to deploy in dist/wasm

# TODOS
A github action is desired to automate the setup and build process.
	see https://github.com/marketplace/actions/install-qt for action to install qt.
		this needs some work because it doesn't support building wasm which is one of the end goes of this project
