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

echo "PRE_TARGETDEPS += $(pwd)/rust/target/${RUSTTARGET}/release/lib${PROJECT_NAME/"-"/"_"}.a" >> $BUILDDIR/$PROJECT_NAME.pro
echo "LIBS += -L$(pwd)/rust/target/${RUSTTARGET}/release -l${PROJECT_NAME/"-"/"_"}" >> $BUILDDIR/$PROJECT_NAME.pro
echo "QT += qml quick" >> $BUILDDIR/$PROJECT_NAME.pro

$QMAKE $BUILDDIR/$PROJECT_NAME.pro -o $BUILDDIR/Makefile
