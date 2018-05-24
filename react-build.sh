#!/bin/sh

cd React/app/
yarn build && cp -r build/* ../../Public/
rm -rf build
