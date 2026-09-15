#!/usr/bin/env bash
# Local helper: build one layer
#
#   ./build.sh <distro> <layer> [amd64|arm64] [--push] [extra docker buildx args...]
#
# Examples:
#   ./build.sh alpine labwc                 # native arch build, loads into local docker
#   ./build.sh debian kwin arm64            # cross build via qemu
#   ./build.sh fedora kwin amd64 --push     # push amd64-fedora44-kwin to the registry
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${here}"

distro="${1:?usage: build.sh <distro> <layer> [amd64|arm64] [--push]}"
layer="${2:?usage: build.sh <distro> <layer> [amd64|arm64] [--push]}"
shift 2

arch=""
case "${1:-}" in
  amd64|arm64) arch="$1"; shift ;;
esac
if [[ -z "${arch}" ]]; then
  case "$(uname -m)" in
    x86_64) arch=amd64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) echo "unsupported host arch $(uname -m), pass amd64 or arm64" >&2; exit 1 ;;
  esac
fi

output="--load"
if [[ "${1:-}" == "--push" ]]; then
  output="--push"
  shift
fi

entry="$(python3 scripts/matrix.py --distro "${distro}" --layer "${layer}" --arch "${arch}" \
  | python3 -c 'import json,sys; b=json.load(sys.stdin)["builds"]; print(json.dumps(b[0]))')"

field() { python3 -c 'import json,sys; print(json.load(sys.stdin)[sys.argv[1]])' "$1" <<<"${entry}"; }

dockerfile="$(field dockerfile)"
platform="$(field platform)"
version="$(field version)"
image="$(field image)"

echo "==> ${image}  (${dockerfile}, ${platform}, DISTRO_VERSION=${version})"
exec docker buildx build \
  --file "${dockerfile}" \
  --platform "${platform}" \
  --build-arg "DISTRO_VERSION=${version}" \
  --provenance=false \
  --sbom=false \
  --pull \
  --no-cache \
  --tag "${image}" \
  ${output} \
  "$@" \
  .
