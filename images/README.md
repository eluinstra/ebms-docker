# Docker Images

## Version

`env.sh` pins the version that `build.sh`, `push.sh` and `manifest.sh`
build and push. After a new release, bump it (and the `examples/*/.env`
files) from the repo root:

```sh
./bump.sh 2.20.9        # or: ./bump.sh (latest eluinstra/ebms-admin release)
```

## Prerequisites to build cross platform on WSL2

Register QEMU binfmt handlers

```sh
docker run --privileged --rm tonistiigi/binfmt --install all
```

Check if handlers are registered

```sh
docker buildx ls
ls /proc/sys/fs/binfmt_misc/qemu-*
```

## Build, push and publish manifests

Run from this folder:

```sh
cd images
```

Build images:

```sh
./build.sh amd64
./build.sh arm64
./build.sh all
```

Push images:

```sh
./push.sh amd64
./push.sh arm64
./push.sh all
```

Create and push multi-arch manifests:

```sh
./manifest.sh
```

Clean local images for one or both architectures:

```sh
./cleanall.sh amd64
./cleanall.sh arm64
./cleanall.sh all
```
