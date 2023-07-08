#!/bin/bash
set -ex
cd "$(dirname "$0")"/..

if [[ ${SOURCE-} ]]; then
    source $SOURCE
fi

rm -rf $BUILDDIR
mkdir -p $BUILDDIR

# generate the qmake project
pushd src
$QMAKE -project -o ../$BUILDDIR/$PROJECT_NAME.pro
popd
echo "QT += qml quick" >> $BUILDDIR/$PROJECT_NAME.pro

# add the static rust library as target
echo "rustlib.target = $(pwd)/rust/target/${RUSTTARGET}/release/lib${PROJECT_NAME/"-"/"_"}.a" >> $BUILDDIR/$PROJECT_NAME.pro;
if [ -z "${RUSTTARGET}" ]; then
    echo "rustlib.commands = cd ../../rust && cargo b --release" >> $BUILDDIR/$PROJECT_NAME.pro;
else
    echo "rustlib.commands = cd ../../rust && cargo b --release --target ${RUSTTARGET}" >> $BUILDDIR/$PROJECT_NAME.pro;
fi
echo "QMAKE_EXTRA_TARGETS += rustlib" >> $BUILDDIR/$PROJECT_NAME.pro;

# link the static rust library to the target
echo "PRE_TARGETDEPS += $(pwd)/rust/target/${RUSTTARGET}/release/lib${PROJECT_NAME/"-"/"_"}.a" >> $BUILDDIR/$PROJECT_NAME.pro
echo "LIBS += -L$(pwd)/rust/target/${RUSTTARGET}/release -Wl,--whole-archive -l${PROJECT_NAME/"-"/"_"} -Wl,--no-whole-archive" >> $BUILDDIR/$PROJECT_NAME.pro

# generate the makefile
$QMAKE $BUILDDIR/$PROJECT_NAME.pro -o $BUILDDIR/Makefile

# fixup the AR and QMAKE variables for use by rustc
sed -i -e 's|ar cqs|ar|g' -e 's|QMAKE.*qmake|QMAKE = '$QMAKE'|g' $BUILDDIR/Makefile

# force the makefile to rebuild the rust library, which is just an invokation of cargo.
echo "$(pwd)/rust/target/${RUSTTARGET}/release/lib${PROJECT_NAME/"-"/"_"}.a: FORCE" >> $BUILDDIR/Makefile

# export all variables to all subprocesses. this is done so that rustc has all the required flags for the compiler.
echo "export" >> $BUILDDIR/Makefile
