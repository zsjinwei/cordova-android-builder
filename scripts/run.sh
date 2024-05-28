#!/bin/bash

docker run -it -v ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro -v ~/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub:ro  -v ~/.ssh/known_hosts:/root/.ssh/known_hosts:ro -v ./scripts:/opt/scripts -v ./dist:/opt/dist  --rm zsjinwei/cordova-android-builder:1.0.1 bash

