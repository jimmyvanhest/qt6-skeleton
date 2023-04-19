#!/bin/bash
set -ex
cd "$(dirname "$0")"/..

if [[ ${SOURCE-} ]]; then
	source $SOURCE
fi

rm -rf $BUILDDIR
mkdir -p $BUILDDIR

pushd src
$QMAKE -project -o ../$BUILDDIR/$PROJECT_NAME.pro
popd

echo 'QT += qml quick' >> $BUILDDIR/$PROJECT_NAME.pro

$QMAKE $BUILDDIR/$PROJECT_NAME.pro -o $BUILDDIR/Makefile
