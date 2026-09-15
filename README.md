# selkies-layers

Prebuilt, patched components for the LinuxServer.io Selkies images.

Images live at `ghcr.io/linuxserver/selkies-layers`.

## Layers

| Layer | Contents | Distros |
| --- | --- | --- |
| `labwc` | patched labwc 0.9.7 (`/usr/bin/labwc`), plus pinned wlroots 0.19.3 (`/usr/lib/<libdir>/libwlroots-0.19.so*`) on distros that lack a packaged wlroots0.19 (arch, debian, ubuntu, kali) | alpine, arch, debian, ubuntu, fedora, kali |
| `wtype` | linuxserver waylandtyper build (`/usr/bin/wtype`) | alpine, arch, debian, ubuntu, fedora, kali |
| `selkies-desktop` | selkies-desktop (`/usr/bin/selkies-desktop`) | alpine, arch, debian, ubuntu, fedora, kali |
| `kwin` | patched `libkwin.so.6.*` and the kwin `screencast.so` plugin, built from the distro's own kwin source package so it matches the packaged version to support dual monitors | alpine, arch, fedora, ubuntu, kali |
| `xvfb` | XLibre Xvfb (`/usr/bin/Xvfb`) from the `xlibre-xserver-25.2.2` tag with glamor + DRI3 (`-glamor -dri /dev/dri/renderD###`), patched so the screen pixmap lives on the GPU and the framebuffer follows RandR resizes (no `-screen` needed) | alpine, arch, debian, ubuntu, fedora, kali |

Every file inside a layer image sits at its final path, so downstream usage is
a single copy:

```dockerfile
# Dockerfile (amd64)
COPY --from=ghcr.io/linuxserver/selkies-layers:debiantrixie-labwc / /
COPY --from=ghcr.io/linuxserver/selkies-layers:debiantrixie-wtype / /

# Dockerfile.aarch64
COPY --from=ghcr.io/linuxserver/selkies-layers:arm64v8-debiantrixie-labwc / /
COPY --from=ghcr.io/linuxserver/selkies-layers:arm64v8-debiantrixie-wtype / /
```

## Tags

Per layer three tags are pushed:

```
ghcr.io/linuxserver/selkies-layers:amd64-alpine324-labwc
ghcr.io/linuxserver/selkies-layers:arm64v8-alpine324-labwc
ghcr.io/linuxserver/selkies-layers:alpine324-labwc        # multi-arch manifest
```

Current bases:

| distro | version | tag base |
| --- | --- | --- |
| alpine | 3.24 | `alpine324` |
| arch | arch | `arch` |
| debian | trixie | `debiantrixie` |
| ubuntu | resolute | `ubunturesolute` |
| fedora | 44 | `fedora44` |
| kali | kali | `kali` |

## Building locally

```
./build.sh alpine labwc                # native arch, loads into local docker
./build.sh fedora kwin arm64           # cross build via qemu
./build.sh debian wtype amd64 --push   # push the arch tag
python3 scripts/matrix.py              # print the full matrix as JSON
```
