#!/bin/bash
set -ex
cd "$(dirname "$0")"/..

CATEGORIES="Qt;Graphics;"

mkdir -p dist/linux/AppDir/usr/share/applications/

echo -e "[Desktop Entry]\nType=Application\nName=${PROJECT_NAME}\nExec=${PROJECT_NAME}\nIcon=logo\nCategories=${CATEGORIES}" > dist/linux/AppDir/usr/share/applications/${PROJECT_NAME}.desktop

QMAKE=$QMAKELINUX QML_SOURCES_PATHS=./src ${PACKAGEDIR}/linuxdeploy-x86_64.AppImage -v2 --appdir dist/linux/AppDir -e build/linux/${PROJECT_NAME} -i logo.svg -d dist/linux/AppDir/usr/share/applications/${PROJECT_NAME}.desktop --plugin qt --output appimage

mv ${PROJECT_NAME}-${VERSION}-${APPIMAGEARCH}.AppImage dist/linux

rm -rf dist/linux/AppDir
