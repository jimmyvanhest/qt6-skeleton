# tool variables
PACKAGEDIR=$(realpath ./)/packages
export PACKAGEDIR
QMAKELINUX=$(PACKAGEDIR)/Qt/6.2.4/gcc_64/bin/qmake
export QMAKELINUX
QMAKEWASM=$(PACKAGEDIR)/Qt/6.2.4/wasm_32/bin/qmake
QMAKEANDROID=$(PACKAGEDIR)/Qt/6.2.4/android_armv7/bin/qmake
JAVA_HOME=/usr/lib/jvm/default-java
export JAVA_HOME
ANDROID_SDK_ROOT=$(PACKAGEDIR)/Android
export ANDROID_SDK_ROOT
ANDROID_NDK_ROOT=$(PACKAGEDIR)/Android/ndk/23.1.7779620
export ANDROID_NDK_ROOT

# project variables
# TODO get from rust project
PROJECT_NAME=qt6-skeleton
export PROJECT_NAME
VERSION=1.0
export VERSION

# debian package variables
DEPARCH=$(shell dpkg-architecture -q DEB_TARGET_ARCH)
export DEPARCH

# AppImage package variables
APPIMAGEARCH=$(shell arch)
export APPIMAGEARCH

SHELL := /bin/bash

help:
	@echo specify one or more of the following targets:
	@echo - dev-install\(requires the environment variables QTMAIL and QTPWD to be set to your qt credentials when Qt still needs to be installed\)
	@echo - dev-uninstall
	@echo - linux
	@echo - run-linux
	@echo - wasm
	@echo - run-wasm
	@echo - android
	@echo - run-android
	@echo - dist

FORCE:



$(PACKAGEDIR)/linuxdeploy-x86_64.AppImage:
	mkdir -p $(PACKAGEDIR)
	wget -nv -NP $(PACKAGEDIR) https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
	chmod +x $@
$(PACKAGEDIR)/linuxdeploy-plugin-qt-x86_64.AppImage:
	mkdir -p $(PACKAGEDIR)
	wget -nv -NP $(PACKAGEDIR) https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage
	chmod +x $@
$(PACKAGEDIR)/qt-unified-linux-x64-online.run:
	mkdir -p $(PACKAGEDIR)
	wget -nv -NP $(PACKAGEDIR) https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage https://download.qt.io/official_releases/online_installers/qt-unified-linux-x64-online.run
	chmod +x $@
$(PACKAGEDIR)/commandlinetools-linux-9477386_latest.zip:
	mkdir -p $(PACKAGEDIR)
	wget -nv -NP $(PACKAGEDIR) https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip

$(PACKAGEDIR)/Qt: $(PACKAGEDIR)/qt-unified-linux-x64-online.run
	mkdir -p $(PACKAGEDIR)
	rm -rf $(PACKAGEDIR)/Qt
	mkdir $(PACKAGEDIR)/Qt
	echo "Yes" | $(PACKAGEDIR)/qt-unified-linux-x64-online.run in qt.qt6.624.gcc_64 qt.qt6.624.wasm_32 qt.qt6.624.android -m $(QTMAIL) --pw $(QTPWD) --na --ao --al --rm --nd --nf -t $(PACKAGEDIR)/Qt

$(PACKAGEDIR)/emsdk:
	mkdir -p $(PACKAGEDIR)
	cd $(PACKAGEDIR); git clone https://github.com/emscripten-core/emsdk.git
	$(PACKAGEDIR)/emsdk/emsdk install 2.0.14
	$(PACKAGEDIR)/emsdk/emsdk activate 2.0.14

$(ANDROID_SDK_ROOT): $(PACKAGEDIR)/commandlinetools-linux-9477386_latest.zip
	rm -rf $@
	mkdir -p $@
	unzip -q -d $@ $(PACKAGEDIR)/commandlinetools-linux-9477386_latest.zip
	mv $@/cmdline-tools $@/tools
	mkdir $@/cmdline-tools
	mv $@/tools $@/cmdline-tools
	yes | $@/cmdline-tools/tools/bin/sdkmanager "platforms;android-31" "platform-tools" "build-tools;31.0.0"
	yes | $@/cmdline-tools/tools/bin/sdkmanager "ndk;23.1.7779620"

$(PACKAGEDIR)/.apt:
	mkdir -p $(PACKAGEDIR)
	sudo apt install libgl1-mesa-dev libvulkan-dev libxkbcommon-dev -y
	touch $(PACKAGEDIR)/.apt

.PHONY: dev-install
dev-install: $(PACKAGEDIR)/.apt $(PACKAGEDIR)/linuxdeploy-x86_64.AppImage $(PACKAGEDIR)/linuxdeploy-plugin-qt-x86_64.AppImage $(PACKAGEDIR)/Qt $(PACKAGEDIR)/emsdk $(ANDROID_SDK_ROOT)

.PHONY: dev-uninstall
dev-uninstall:
	sudo apt-mark auto libgl1-mesa-dev libvulkan-dev libxkbcommon-dev
	sudo apt autoremove -y
	rm -rf $(PACKAGEDIR)

rust/target/release/lib$(subst -,_,${PROJECT_NAME}).a: export QMAKE = $(QMAKELINUX)
rust/target/release/lib$(subst -,_,${PROJECT_NAME}).a: FORCE $(PACKAGEDIR)/Qt
	cd rust && cargo b --release
src/plugins.cc: rust/target/release/lib$(subst -,_,${PROJECT_NAME}).a scripts/generate_q_static_plugin_import.sh
	scripts/generate_q_static_plugin_import.sh

rust/target/wasm32-unknown-emscripten/release/lib$(subst -,_,${PROJECT_NAME}).a: export QMAKE = $(QMAKEWASM)
rust/target/wasm32-unknown-emscripten/release/lib$(subst -,_,${PROJECT_NAME}).a: FORCE $(PACKAGEDIR)/Qt
	source $(PACKAGEDIR)/emsdk/emsdk_env.sh && cd rust && cargo b --release --target wasm32-unknown-emscripten

rust/target/armv7-linux-androideabi/release/lib$(subst -,_,${PROJECT_NAME}).a: export QMAKE = $(QMAKEANDROID)
rust/target/armv7-linux-androideabi/release/lib$(subst -,_,${PROJECT_NAME}).a: export CXX = $(PWD)/packages/Android/ndk/23.1.7779620/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++
rust/target/armv7-linux-androideabi/release/lib$(subst -,_,${PROJECT_NAME}).a: export CXXFLAGS = -target armv7a-linux-androideabi23 -fno-limit-debug-info -fPIC -fstack-protector-strong -DANDROID -O2 -mthumb -Oz -std=gnu++1z -Wall -W -D_REENTRANT -fPIC -DQT_NO_DEBUG -DQT_QUICK_LIB -DQT_OPENGL_LIB -DQT_GUI_LIB -DQT_QMLMODELS_LIB -DQT_QML_LIB -DQT_NETWORK_LIB -DQT_CORE_LIB
rust/target/armv7-linux-androideabi/release/lib$(subst -,_,${PROJECT_NAME}).a: export AR = $(PWD)/packages/Android/ndk/23.1.7779620/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-ar
rust/target/armv7-linux-androideabi/release/lib$(subst -,_,${PROJECT_NAME}).a: FORCE $(PACKAGEDIR)/Qt
	cd rust && RUST_BACKTRACE=full cargo b --release --target armv7-linux-androideabi


build/linux: export QMAKE = $(QMAKELINUX)
build/linux: export BUILDDIR = build/linux
build/linux: $(PACKAGEDIR)/Qt scripts/qmake-build.sh src/plugins.cc
	scripts/qmake-build.sh
build/linux/$(PROJECT_NAME): rust/target/release/lib$(subst -,_,${PROJECT_NAME}).a
build/linux/$(PROJECT_NAME): FORCE build/linux
	$(MAKE) -C build/linux
.PHONY: linux
linux: build/linux/$(PROJECT_NAME)

.PHONY: run-linux
run-linux: linux
	build/linux/$(PROJECT_NAME)

dist/linux/$(PROJECT_NAME)-$(VERSION)-$(APPIMAGEARCH).AppImage: $(PACKAGEDIR)/linuxdeploy-x86_64.AppImage $(PACKAGEDIR)/linuxdeploy-plugin-qt-x86_64.AppImage build/linux/$(PROJECT_NAME) scripts/package-appimage.sh
	scripts/package-appimage.sh



build/wasm: export QMAKE = $(QMAKEWASM)
build/wasm: export BUILDDIR = build/wasm
build/wasm: export SOURCE = $(PACKAGEDIR)/emsdk/emsdk_env.sh
build/wasm: export RUSTTARGET = wasm32-unknown-emscripten
build/wasm: $(PACKAGEDIR)/Qt $(PACKAGEDIR)/emsdk scripts/qmake-build.sh src/plugins.cc
	scripts/qmake-build.sh
build/wasm/qtlogo.svg: FORCE logo.svg build/wasm
	rsync -ct logo.svg build/wasm/qtlogo.svg
build/wasm/$(PROJECT_NAME).html: rust/target/wasm32-unknown-emscripten/release/lib$(subst -,_,${PROJECT_NAME}).a
build/wasm/$(PROJECT_NAME).html: FORCE build/wasm
	source $(PACKAGEDIR)/emsdk/emsdk_env.sh && $(MAKE) -C build/wasm
.PHONY: wasm
wasm: build/wasm/$(PROJECT_NAME).html build/wasm/qtlogo.svg

.PHONY: run-wasm
run-wasm: wasm
	source $(PACKAGEDIR)/emsdk/emsdk_env.sh && emrun build/wasm/$(PROJECT_NAME).html

dist/wasm/$(PROJECT_NAME).tar.gz: build/wasm/$(PROJECT_NAME).html build/wasm/qtlogo.svg
	mkdir -p dist/wasm/$(PROJECT_NAME)
	cp build/wasm/$(PROJECT_NAME).html build/wasm/$(PROJECT_NAME).js build/wasm/$(PROJECT_NAME).wasm build/wasm/qtloader.js build/wasm/qtlogo.svg dist/wasm/$(PROJECT_NAME)
	cd dist/wasm/; tar -czvf $(PROJECT_NAME).tar.gz $(PROJECT_NAME)
	rm -rf dist/wasm/$(PROJECT_NAME)



build/android: export QMAKE = $(QMAKEANDROID)
build/android: export BUILDDIR = build/android
build/android: export RUSTTARGET = armv7-linux-androideabi
build/android: $(PACKAGEDIR)/Qt $(ANDROID_SDK_ROOT) scripts/qmake-build.sh src/plugins.cc
	scripts/qmake-build.sh
build/android/android-build/$(PROJECT_NAME).apk: rust/target/armv7-linux-androideabi/release/lib$(subst -,_,${PROJECT_NAME}).a
build/android/android-build/$(PROJECT_NAME).apk: FORCE build/android
	$(MAKE) -C build/android aab
.PHONY: android
android: build/android/android-build/$(PROJECT_NAME).apk

.PHONY: run-android
run-android: build/android/android-build/$(PROJECT_NAME).apk
	scripts/adb-run.sh $<

dist/android/$(PROJECT_NAME).apk: build/android/android-build/$(PROJECT_NAME).apk
	mkdir -p dist/android
	cp build/android/android-build/$(PROJECT_NAME).apk dist/android/$(PROJECT_NAME).apk



.PHONY: dist
dist: dist/linux/$(PROJECT_NAME)-$(VERSION)-$(APPIMAGEARCH).AppImage
dist: dist/wasm/$(PROJECT_NAME).tar.gz
dist: dist/android/$(PROJECT_NAME).apk



.PHONY: clean
clean:
	rm -rf build dist src/plugins.cc
	cd rust && cargo clean
