#!/bin/sh

echo "Remove old Public folder"
rm -rf Public
cd React/app/
echo "Install JS depedencies for React build for production and replace Public folder"
yarn install && yarn build && mv build ../../Public
