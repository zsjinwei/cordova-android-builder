#!/bin/bash

export VENDOR=gtv
export PROJECT_NAME=home-care-service-phone
export CORDOVA_ANDROID_GRADLE_DISTRIBUTION_URL=file:///tmp/gradle-7.6-all.zip

mkdir /opt/src
mkdir /opt/dist
mkdir -p /opt/src-${VENDOR}

if [ -d "/opt/src/${PROJECT_NAME}" ]; then
  echo "project directory already exists"
else
  echo "project directory is not exists"
  cd /opt/src
  (sleep 5 && while [ 1 ]; do sleep 5; echo yes; done) | git clone git@git.tigeek.com:huangjinwei/home-care-service-phone.git
fi

cp -ri /opt/src/${PROJECT_NAME} /opt/src-${VENDOR}/${PROJECT_NAME}
cd /opt/src-${VENDOR}/${PROJECT_NAME}

if [ -d "/opt/src/${PROJECT_NAME}" ]; then
  echo "copy /opt/prebuilds/node_modules to /opt/src-${VENDOR}/${PROJECT_NAME}"
  cp -ri /opt/prebuilds/node_modules /opt/src-${VENDOR}/${PROJECT_NAME}
fi

if [ -e "/opt/prebuilds/gradle-caches.tar.gz" ]; then
  echo "copy /opt/prebuilds/yarn.lock to /opt/src-${VENDOR}/${PROJECT_NAME}"
  cp /opt/prebuilds/yarn.lock /opt/src-${VENDOR}/${PROJECT_NAME}
fi

if [ -e "/opt/prebuilds/gradle-caches.tar.gz" ]; then
  echo "gradle-caches rebuild file exists, unpack to /opt/gradle-7.6/"
  tar xzf /opt/prebuilds/gradle-caches.tar.gz -C /opt/gradle-7.6/
else
  echo "gradle-caches prebuild file not exists"
fi

if [ -e "/opt/prebuilds/yarn-cache.tar.gz" ]; then
  echo "yarn-cache rebuild file exists, unpack to $(yarn cache dir)"
  tar xzf /opt/prebuilds/yarn-cache.tar.gz -C /
else
  echo "yarn-cache prebuild file not exists"
fi

if [ -e "/opt/prebuilds/node_modules.tar.gz" ]; then
  echo "gradle-caches rebuild file exists, unpack to /opt/src-${VENDOR}/${PROJECT_NAME}"
  tar xzf /opt/prebuilds/node_modules.tar.gz -C /opt/src-${VENDOR}/${PROJECT_NAME}
else
  echo "node_modules prebuild file not exists"
fi

if [ -e "/opt/prebuilds/yarn.lock" ]; then
  echo "yarn.lock file exists, copy to /opt/src-${VENDOR}/${PROJECT_NAME}"
  cp /opt/prebuilds/yarn.lock /opt/src-${VENDOR}/${PROJECT_NAME}
else
  echo "yarn.lock file not exists"
fi

yarn install
cd src-cordova
mkdir www
rm ./package.json && cp ../vendor/${VENDOR}/cordova/package.json ./package.json
cordova platform add android
echo "systemProp.jdk.tls.client.protocols=TLSv1.2,TLSv1.3" >> platforms/android/gradle.properties
echo "systemProp.https.protocols=TLSv1.2,TLSv1.3" >> platforms/android/gradle.properties
cd ..
# npx quasar build -m android
QUASAR_CLI="npx quasar" ./release.sh android ${VENDOR} yes
# cp ./dist/cordova/android/apk/release/* /opt/dist/
cp /opt/src-${VENDOR}/${PROJECT_NAME}/dist/cordova/android/apk/release/gtv-com.gtv.homecare.apk /opt/dist/
