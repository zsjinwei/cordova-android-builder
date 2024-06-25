#!/bin/bash

git pull

docker run -it -v ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro -v ~/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub:ro  -v ~/.ssh/known_hosts:/root/.ssh/known_hosts:ro -v ./scripts:/opt/scripts -v ./dist:/opt/dist -v ./prebuilds:/opt/prebuilds  --rm zsjinwei/cordova-android-builder:latest bash
