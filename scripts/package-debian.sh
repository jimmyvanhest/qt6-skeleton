#!/bin/bash
set -ex
cd "$(dirname "$0")"/..

RUNTIMEDEPS="qml6-module-qtqml-workerscript qml6-module-qtquick qml6-module-qtquick-window"

rm -rf dist/linux/${PROJECT_NAME}_${VERSION}_1_${DEPARCH}
mkdir -p dist/linux/${PROJECT_NAME}_${VERSION}_1_${DEPARCH}/usr/bin

cp build/linux/${PROJECT_NAME} dist/linux/${PROJECT_NAME}_${VERSION}_1_${DEPARCH}/usr/bin/

mkdir dist/linux/${PROJECT_NAME}_${VERSION}_1_${DEPARCH}/debian
echo -e "Source: ${PROJECT_NAME}\nMaintainer: ${MAINTAINER}\nStandard-Version: 1.0.0.0\n\nPackage: ${PROJECT_NAME}\nArchitecture: ${DEPARCH}\nDescription: ${DESCRIPTION}" > dist/linux/${PROJECT_NAME}_${VERSION}_1_${DEPARCH}/debian/control

mkdir -p dist/linux/${PROJECT_NAME}_${VERSION}_1_${DEPARCH}/DEBIAN
echo -e "Package: ${PROJECT_NAME}\nVersion: ${VERSION}\nArchitecture: ${DEPARCH}\nMaintainer: ${MAINTAINER}\nDescription: ${DESCRIPTION}" >> dist/linux/${PROJECT_NAME}_${VERSION}_1_${DEPARCH}/DEBIAN/control
pushd dist/linux/${PROJECT_NAME}_${VERSION}_1_${DEPARCH}
dpkg-shlibdeps -O usr/bin/${PROJECT_NAME} | cut -d ":" -f2- | awk '!x{x=sub("=",": ")}7' >> DEBIAN/control
popd
truncate -s -1 dist/linux/${PROJECT_NAME}_${VERSION}_1_${DEPARCH}/DEBIAN/control
dpkg-query -W ${RUNTIMEDEPS} | awk -F'[: \t+]' '{ printf ", %s (>=%s)", $1, $3 }' >> dist/linux/${PROJECT_NAME}_${VERSION}_1_${DEPARCH}/DEBIAN/control
echo "" >> dist/linux/${PROJECT_NAME}_${VERSION}_1_${DEPARCH}/DEBIAN/control

dpkg-deb --build --root-owner-group dist/linux/${PROJECT_NAME}_${VERSION}_1_${DEPARCH}

rm -rf dist/linux/${PROJECT_NAME}_${VERSION}_1_${DEPARCH}/
