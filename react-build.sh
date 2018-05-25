#!/bin/sh

cd React/app/
yarn install && yarn build && cp -r build/* ../../Public/
echo "Static js and css are copied into Public directory"
rm -rf build
echo "Build folder is deleted"
