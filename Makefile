# linux variables
QMAKENATIVE=qmake6
QMAKEWASM=~/packages/Qt/6.5.0/wasm_singlethread/bin/qmake
ARCH=$(shell dpkg-architecture -q DEB_TARGET_ARCH)

# project variables
PROJECT_NAME=qt6-skeleton
VERSION=1.0
MAINTAINER=Jimmy van Hest<jimmyvanhest@gmail.com>
DESCRIPTION=Qt 6 skeleton application

# debian package variables
RUNTIMEDEPS=qml6-module-qtqml-workerscript qml6-module-qtquick qml6-module-qtquick-window

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

.PHONY: native wasm
native: build/native
	$(MAKE) -C build/native
wasm: build/wasm
	$(MAKE) -C build/wasm
	@if test -f "logo.svg"; then cp logo.svg build/wasm/logo.svg; else mv build/wasm/qtlogo.svg build/wasm/logo.svg; fi
	@sed -i 's/qtlogo.svg/logo.svg/' build/wasm/qt6-skeleton.html

build/native/$(PROJECT_NAME): | native

dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH).deb: build/native/$(PROJECT_NAME) | Makefile
	@echo building debian package
	@rm -rf dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)
	@mkdir -p dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/usr/bin
	@cp build/native/$(PROJECT_NAME) dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/usr/bin/
	@mkdir dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/debian
	@echo 'Source: $(PROJECT_NAME)' > dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/debian/control
	@echo 'Maintainer: $(MAINTAINER)' >> dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/debian/control
	@echo 'Standard-Version: 1.0.0.0' >> dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/debian/control
	@echo '' >> dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/debian/control
	@echo 'Package: $(PROJECT_NAME)' >> dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/debian/control
	@echo 'Architecture: $(ARCH)' >> dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/debian/control
	@echo 'Description: $(DESCRIPTION)' >> dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/debian/control
	@mkdir -p dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/DEBIAN
	@echo 'Package: $(PROJECT_NAME)' > dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/DEBIAN/control
	@echo 'Version: $(VERSION)' >> dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/DEBIAN/control
	@echo 'Architecture: $(ARCH)' >> dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/DEBIAN/control
	@echo 'Maintainer: $(MAINTAINER)' >> dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/DEBIAN/control
	@echo 'Description: $(DESCRIPTION)' >> dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/DEBIAN/control
	@cd dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH); dpkg-shlibdeps -O usr/bin/qt6-skeleton | cut -d ":" -f2- | awk '!x{x=sub("=",": ")}7' >> DEBIAN/control
	@truncate -s -1 dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/DEBIAN/control
	@dpkg-query -W $(RUNTIMEDEPS) | awk -F'[: \t+]' '{ printf ", %s (>=%s)", $$1, $$3 }' >> dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/DEBIAN/control
	@echo "" >> dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/DEBIAN/control
	@dpkg-deb --build --root-owner-group dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)
	@rm -rf dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH)/
	@echo finished building debian package

.PHONY: dist
dist: dist/linux/$(PROJECT_NAME)_$(VERSION)_1_$(ARCH).deb

.PHONY: clean
clean:
	rm -rf build dist
