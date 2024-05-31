#!/bin/bash

cd /opt/src
(sleep 5 && while [ 1 ]; do sleep 5; echo yes; done) | git clone git@git.tigeek.com:huangjinwei/home-care-service-phone.git
cd /opt/src/home-care-service-phone
export CORDOVA_ANDROID_GRADLE_DISTRIBUTION_URL=file:///tmp/gradle-7.6-all.zip
yarn install
cd src-cordova
mkdir www
cordova platform add android
echo "systemProp.jdk.tls.client.protocols=TLSv1.2,TLSv1.3" >> platforms/android/gradle.properties
echo "systemProp.https.protocols=TLSv1.2,TLSv1.3" >> platforms/android/gradle.properties
cd ..
yarn add gifsicle
# npx quasar build -m android
QUASAR_CLI="npx quasar" ./release.sh android yishou yes
cp ./dist/cordova/android/apk/release/* /opt/dist/
