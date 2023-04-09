# linux variables
QMAKENATIVE=qmake6
PACKAGEDIR=~/packages
QMAKEWASM=$(PACKAGEDIR)/Qt/6.5.0/wasm_singlethread/bin/qmake
ARCH=$(shell dpkg-architecture -q DEB_TARGET_ARCH)

# project variables
PROJECT_NAME=qt6-skeleton
APPVERSION=1.0
MAINTAINER=Jimmy van Hest<jimmyvanhest@gmail.com>
DESCRIPTION=Qt 6 skeleton application

# debian package variables
RUNTIMEDEPS=qml6-module-qtqml-workerscript qml6-module-qtquick qml6-module-qtquick-window

# AppImage package variables
CATEGORIES=Qt;Graphics;
APPIMAGEARCH=$(shell arch)

help:
	@echo specify one or more of the following targets:
	@echo - native
	@echo - wasm
	@echo - dist

FILES=qml.qrc src/main.cc

build/native: Makefile
	@rm -rf build/native
	@mkdir -p build/native
	$(QMAKENATIVE) -project -o build/native/$(PROJECT_NAME).pro -nopwd $(realpath $(FILES))
	@echo 'QT += qml quick' >> build/native/$(PROJECT_NAME).pro
	$(QMAKENATIVE) build/native/$(PROJECT_NAME).pro -o build/native/Makefile
build/wasm: Makefile
	@rm -rf build/wasm
	@mkdir -p build/wasm
	$(QMAKEWASM) -project -o build/wasm/$(PROJECT_NAME).pro -nopwd $(realpath $(FILES))
	@echo 'QT += qml quick' >> build/wasm/$(PROJECT_NAME).pro
	$(QMAKEWASM) build/wasm/$(PROJECT_NAME).pro -o build/wasm/Makefile

FORCE:
build/native/$(PROJECT_NAME): FORCE build/native
	$(MAKE) -C build/native

.PHONY: native wasm
native: build/native/$(PROJECT_NAME)
wasm: build/wasm
	$(MAKE) -C build/wasm
	@if cp logo.svg build/wasm/logo.svg
	@sed -i 's/qtlogo.svg/logo.svg/' build/wasm/qt6-skeleton.html

dist/linux/$(PROJECT_NAME)_$(APPVERSION)_1_$(ARCH).deb: build/native/$(PROJECT_NAME) | Makefile
	@echo building debian package
	@rm -rf dist/linux/$(PROJECT_NAME)_$(APPVERSION)_1_$(ARCH)
	@mkdir -p dist/linux/$(PROJECT_NAME)_$(APPVERSION)_1_$(ARCH)/usr/bin
	@cp build/native/$(PROJECT_NAME) dist/linux/$(PROJECT_NAME)_$(APPVERSION)_1_$(ARCH)/usr/bin/
	@mkdir dist/linux/$(PROJECT_NAME)_$(APPVERSION)_1_$(ARCH)/debian
	@echo 'Source: $(PROJECT_NAME)\nMaintainer: $(MAINTAINER)\nStandard-Version: 1.0.0.0\n\nPackage: $(PROJECT_NAME)\nArchitecture: $(ARCH)\nDescription: $(DESCRIPTION)' > dist/linux/$(PROJECT_NAME)_$(APPVERSION)_1_$(ARCH)/debian/control
	@mkdir -p dist/linux/$(PROJECT_NAME)_$(APPVERSION)_1_$(ARCH)/DEBIAN
	@echo 'Package: $(PROJECT_NAME)\nVersion: $(APPVERSION)\nArchitecture: $(ARCH)\nMaintainer: $(MAINTAINER)\nDescription: $(DESCRIPTION)' >> dist/linux/$(PROJECT_NAME)_$(APPVERSION)_1_$(ARCH)/DEBIAN/control
	@cd dist/linux/$(PROJECT_NAME)_$(APPVERSION)_1_$(ARCH); dpkg-shlibdeps -O usr/bin/qt6-skeleton | cut -d ":" -f2- | awk '!x{x=sub("=",": ")}7' >> DEBIAN/control
	@truncate -s -1 dist/linux/$(PROJECT_NAME)_$(APPVERSION)_1_$(ARCH)/DEBIAN/control
	@dpkg-query -W $(RUNTIMEDEPS) | awk -F'[: \t+]' '{ printf ", %s (>=%s)", $$1, $$3 }' >> dist/linux/$(PROJECT_NAME)_$(APPVERSION)_1_$(ARCH)/DEBIAN/control
	@echo "" >> dist/linux/$(PROJECT_NAME)_$(APPVERSION)_1_$(ARCH)/DEBIAN/control
	@dpkg-deb --build --root-owner-group dist/linux/$(PROJECT_NAME)_$(APPVERSION)_1_$(ARCH)
	@rm -rf dist/linux/$(PROJECT_NAME)_$(APPVERSION)_1_$(ARCH)/
	@echo finished building debian package

dist/linux/$(PROJECT_NAME)-$(APPVERSION)-$(APPIMAGEARCH).AppImage: export QMAKE = $(QMAKENATIVE)
dist/linux/$(PROJECT_NAME)-$(APPVERSION)-$(APPIMAGEARCH).AppImage: export VERSION = $(APPVERSION)
dist/linux/$(PROJECT_NAME)-$(APPVERSION)-$(APPIMAGEARCH).AppImage: export QML_SOURCES_PATHS = ./
dist/linux/$(PROJECT_NAME)-$(APPVERSION)-$(APPIMAGEARCH).AppImage: build/native/$(PROJECT_NAME) | Makefile
	@mkdir -p dist/linux/AppDir/usr/share/applications/
	@echo "[Desktop Entry]\nType=Application\nName=$(PROJECT_NAME)\nExec=$(PROJECT_NAME)\nIcon=logo\nCategories=$(CATEGORIES)" > dist/linux/AppDir/usr/share/applications/$(PROJECT_NAME).desktop
	@$(PACKAGEDIR)/linuxdeploy-x86_64.AppImage --appdir dist/linux/AppDir -e build/native/$(PROJECT_NAME) -i logo.svg -d dist/linux/AppDir/usr/share/applications/$(PROJECT_NAME).desktop --plugin qt --output appimage
	@mv $(PROJECT_NAME)-$(APPVERSION)-$(APPIMAGEARCH).AppImage dist/linux
	@rm -rf dist/linux/AppDir

.PHONY: dist
dist: dist/linux/$(PROJECT_NAME)_$(APPVERSION)_1_$(ARCH).deb
dist: dist/linux/$(PROJECT_NAME)-$(APPVERSION)-$(APPIMAGEARCH).AppImage

.PHONY: clean
clean:
	rm -rf build dist
