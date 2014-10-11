#!/bin/bash
# compile
coffee --compile *.coffee

# compress
#uglifyjs wwwfiles/js/script.js --mangle --compress --screw-ie8 -o wwwfiles/js/script.js

echo "The files are ready to deploy."
