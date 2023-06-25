#!/bin/bash
set -ex
cd "$(dirname "$0")"/..

echo "#include <QtPlugin>" > src/plugins.cc
readelf -CsWs rust/target/release/lib${PROJECT_NAME/"-"/"_"}.a | grep FUNC | awk '/qt_static_plugin_/{split($NF,a,"qt_static_plugin_"); print "Q_IMPORT_PLUGIN(" substr(a[2], 1, length(a[2])-2) ")"}' >> src/plugins.cc
