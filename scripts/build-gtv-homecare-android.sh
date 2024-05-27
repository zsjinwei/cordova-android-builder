#!/bin/bash

cd /opt/src
(sleep 5 && while [ 1 ]; do sleep 5; echo yes; done) | git clone git@git.tigeek.com:huangjinwei/home-care-service-phone.git
cd /opt/src/home-care-service-phone
yarn install
cd src-cordova
mkdir www
cordova platform add android
echo "systemProp.jdk.tls.client.protocols=TLSv1.2,TLSv1.3" >> platforms/android/gradle.properties
echo "systemProp.https.protocols=TLSv1.2,TLSv1.3" >> platforms/android/gradle.properties
cd ..
# npx quasar build -m android
QUASAR_CLI="npx quasar" ./release.sh gtv android yes
