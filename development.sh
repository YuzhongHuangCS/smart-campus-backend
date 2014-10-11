#!/bin/bash
coffee --watch --compile *.coffee&
nodejs app.js

echo "The development environment has ready!"
