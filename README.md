# 1. 登录虚拟机

ssh suzhenghui@10.2.1.98
密码 #yishouanyang2020

# 2. 运行容器

./scripts/run.sh

# 3. 容器运行后会出现 "root@d35d6617d861:/opt/src#" 类似字样

# 4. 然后开始编译

# 4.1 编译家床易使用以下脚本

/opt/scripts/build-yishou-homecare-android.sh

# 4.2 编译养老易使用以下脚本

/opt/scripts/build-gtv-homecare-android.sh

# Build Cordova Application in Docker

---

Use docker to build cordova applications. For local development, testing, CI/CD...

## Docker repository

https://hub.docker.com/r/hamdifourati/cordova-android-builder/

## Requirements

- Docker

## Installed dependencies

- NodeJS v20 LTS
- Cordova v12.0.0
- Android Platform Tools
- Android Build Tools 33.0.2
- Android 33

## How to

## Pull image from Docker hub

```
docker pull hamdifourati/cordova-android-builder
```

### Run Builder Container

```
# Check dependencies are installed and configured.
docker run -v <local-app-src>:/opt/src --rm hamdifourati/cordova-android-builder cordova requirements

# Build Android apk
docker run -v <local-app-src>:/opt/src --rm hamdifourati/cordova-android-builder cordova build
```

## Interactive shell

> Run a shell inside the conatiner

```
docker run -it -v <local-app-src>:/opt/src --rm hamdifourati/cordova-android-builder bash

root@cordova:/opt/src# cordova platform add android
root@cordova:/opt/src# cordova requirements
root@cordova:/opt/src# cordova build
```

The Generated APK is in: `/opt/src/platforms/android/app/build/outputs/apk/`

## Install Android packages ( build-tools, platform-tools .. )

> Note that this image uses [sdkmanager](https://developer.android.com/studio/command-line/sdkmanager) to manage android packages and comes with some default [packages](#installed-dependencies). You are more likely to need different versions.

### Install using a custom Dockerfile

```
FROM hamdifourati/cordova-android-builder

RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | sdkmanager "platforms;android-30"
```

### Install in interactive shell

```
# attach to your already running container
docker exec -it <cordova-container-name> bash

# Install & Accept linceses
root@cordova:/opt/src# sdkmanager "platforms;android-30"
```

> You can always list available packages either inside the container or directly.

```
docker run -it --rm hamdifourati/cordova-android-builder sdkmanager --list
```

### Enjoy !
