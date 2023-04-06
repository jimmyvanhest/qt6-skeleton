QMAKENATIVE=qmake
QMAKEWASM=~/packages/Qt/6.5.0/wasm_singlethread/bin/qmake
PROJECT_NAME=qt6-skeleton

help:
	@echo specify one or more of the following targets:
	@echo - native
	@echo - wasm

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

.PHONY: clean
clean:
	rm -rf build
