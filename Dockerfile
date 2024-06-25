#https://hub.docker.com/_/openjdk
ARG OPENJDK_VERSION=11
FROM openjdk:${OPENJDK_VERSION}

# Reference default value
ARG OPENJDK_VERSION
#https://github.com/nodesource/distributions/blob/master/README.md
ARG NODEJS_VERSION=20
#https://gradle.org/releases/
ARG GRADLE_VERSION=7.6
#https://www.npmjs.com/package/cordova?activeTab=versions
ARG CORDOVA_VERSION=12.0.0
#https://developer.android.com/studio#command-tools
ARG ANDROID_CMDTOOLS_VERSION=9477386


LABEL maintainer="Huang Jinwei <zsjinwei@foxmail.com>"

WORKDIR /opt/src

ENV JAVA_HOME /usr/local/openjdk-${OPENJDK_VERSION}/
ENV ANDROID_SDK_ROOT /usr/local/android-sdk-linux
ENV ANDROID_HOME $ANDROID_SDK_ROOT
ENV GRADLE_USER_HOME /opt/gradle
ENV PATH $PATH:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$GRADLE_USER_HOME/bin
ENV NODE_OPTIONS --openssl-legacy-provider

# NodeJS
RUN echo https://deb.nodesource.com/setup_${NODEJS_VERSION}.x
RUN curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION}.x | bash -
RUN apt -qq install -y nodejs openssl vim

# Cordova
RUN npm config set registry https://registry.npmmirror.com/
RUN npm i -g cordova@${CORDOVA_VERSION} yarn && yarn config set registry https://registry.npmmirror.com/

# Gradle
RUN curl -so /tmp/gradle-${GRADLE_VERSION}-all.zip https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip && \
    unzip -qd /opt /tmp/gradle-${GRADLE_VERSION}-all.zip && \
    ln -s /opt/gradle-${GRADLE_VERSION} /opt/gradle

# Android
RUN curl -so /tmp/commandlinetools-linux-${ANDROID_CMDTOOLS_VERSION}_latest.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDTOOLS_VERSION}_latest.zip && \
    mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/ && \
    unzip -qd $ANDROID_SDK_ROOT/cmdline-tools/ /tmp/commandlinetools-linux-${ANDROID_CMDTOOLS_VERSION}_latest.zip && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest

# Update and accept licences
COPY android.packages android.packages
RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | sdkmanager --package_file=android.packages
RUN cordova telemetry off

COPY .ssh /root/.ssh
COPY scripts /opt/scripts
COPY prebuilds /opt/prebuilds

RUN mkdir /opt/src-build && \
    cp /opt/prebuilds/package.json /opt/src-build && \
    cp /opt/prebuilds/yarn.lock /opt/src-build && \
    cd /opt/src-build && \
    yarn install --frozen-lockfile && \
    mv /opt/src-build/node_modules /opt/prebuilds/node_modules && \
    mv /opt/src-build/yarn.lock /opt/prebuilds/yarn.lock

