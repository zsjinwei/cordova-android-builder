#!/bin/bash

export VENDOR=gtv
export PACKAGE_ID="com.${VENDOR}.homecare"
export PROJECT_NAME=home-care-service-phone
export CORDOVA_ANDROID_GRADLE_DISTRIBUTION_URL=file:///tmp/gradle-7.6-all.zip
export CLONE_SOURCE_DIR=/opt/src
export BUILD_SOURCE_DIR=/opt/src-build
export DIST_DIR=/opt/dist
export PREBUILDS_DIR=/opt/prebuilds

mkdir ${CLONE_SOURCE_DIR}
mkdir ${DIST_DIR}
mkdir ${BUILD_SOURCE_DIR}

if [ -d "${CLONE_SOURCE_DIR}/${PROJECT_NAME}" ]; then
  echo "project directory already exists"
else
  echo "project directory is not exists"
  cd ${CLONE_SOURCE_DIR}
  (sleep 5 && while [ 1 ]; do sleep 5; echo yes; done) | git clone git@git.tigeek.com:huangjinwei/home-care-service-phone.git
fi

if [ -d "${BUILD_SOURCE_DIR}" ]; then
  echo "clean build dir ${BUILD_SOURCE_DIR}"
  rm -rf ${BUILD_SOURCE_DIR}/*
fi

cp -ri ${CLONE_SOURCE_DIR}/${PROJECT_NAME}/. ${BUILD_SOURCE_DIR}/
cd ${BUILD_SOURCE_DIR}

export PACKAGE_VER=$(jq -r '.version' ${BUILD_SOURCE_DIR}/package.json)

if [ -d "${PREBUILDS_DIR}/node_modules" ]; then
  echo "copy ${PREBUILDS_DIR}/node_modules to ${BUILD_SOURCE_DIR}"
  cp -ri ${PREBUILDS_DIR}/node_modules ${BUILD_SOURCE_DIR}
fi

if [ -e "${PREBUILDS_DIR}/yarn.lock" ]; then
  echo "yarn.lock file exists, copy to ${BUILD_SOURCE_DIR}"
  cp ${PREBUILDS_DIR}/yarn.lock ${BUILD_SOURCE_DIR}
else
  echo "yarn.lock file not exists"
fi

if [ -e "${PREBUILDS_DIR}/gradle-caches.tar.gz" ]; then
  echo "gradle-caches rebuild file exists, unpack to /opt/gradle-7.6/"
  tar xzf ${PREBUILDS_DIR}/gradle-caches.tar.gz -C /opt/gradle-7.6/
else
  echo "gradle-caches prebuild file not exists"
fi

if [ -e "${PREBUILDS_DIR}/yarn-cache.tar.gz" ]; then
  echo "yarn-cache rebuild file exists, unpack to $(yarn cache dir)"
  tar xzf ${PREBUILDS_DIR}/yarn-cache.tar.gz -C /
else
  echo "yarn-cache prebuild file not exists"
fi

if [ -e "${PREBUILDS_DIR}/node_modules.tar.gz" ]; then
  echo "gradle-caches rebuild file exists, unpack to ${BUILD_SOURCE_DIR}"
  if [ -d "${BUILD_SOURCE_DIR}/node_modules" ]; then
    rm -rf ${BUILD_SOURCE_DIR}/node_modules
  fi
  tar xzf ${PREBUILDS_DIR}/node_modules.tar.gz -C ${BUILD_SOURCE_DIR}
else
  echo "node_modules prebuild file not exists"
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
# cp ./dist/cordova/android/apk/release/* ${DIST_DIR}/
# cp ${BUILD_SOURCE_DIR}/dist/cordova/android/apk/release/${PACKAGE_ID}.apk ${DIST_DIR}/
cp ${BUILD_SOURCE_DIR}/src-cordova/platforms/android/app/build/outputs/apk/release/app-release.apk ${DIST_DIR}/${PACKAGE_ID}-${PACKAGE_VER}.apk
