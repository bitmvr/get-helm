#!/usr/bin/env bash

# Download Link Examples by OS
## macOS - https://get.helm.sh/helm-v2.16.0-darwin-amd64.tar.gz
## WinOS - https://get.helm.sh/helm-v2.16.0-windows-amd64.zip
## Linux - https://get.helm.sh/helm-v2.16.0-linux-amd64.tar.gz
readonly VERSION="$1"

if [ -z $VERSION ]; then
  echo "Please provide a valid semantic version number for Helm."
  exit 1
fi

getHelm::OSConfig(){
  local get_system_name
  get_system_name="$(uname | tr '[:upper:]' '[:lower:]')"
  case "$get_system_name" in
    darwin)
      readonly HOST_OS="darwin"
      readonly EXT="tar.gz"
      readonly ARCH="amd64"
    ;;
    mingw64*)
      readonly HOST_OS="windows"
      readonly EXT="zip"
      readonly ARCH="amd64"
    ;;
    linux*)
      readonly HOST_OS="linux"
      readonly EXT="tar.gz"
      readonly ARCH="amd64"
    ;;
    *)
      HOST_OS="unknown"
      return 1
    ;;
  esac
}

getHelm::getArtifact(){
  local download_endpoint
  download_endpoint="https://get.helm.sh/helm-v${VERSION}-${HOST_OS}-${ARCH}.${EXT}"
  curl -sO "$download_endpoint"
}

getHelm::init(){
  if ! getHelm::OSConfig; then
    echo "Could not determine your operating system."
    exit 1
  fi

  if ! getHelm::getArtifact; then
    echo "Unable to download Helm v${VERSION}."
    exit 1
  fi  

  echo "Successfully download Helm v${VERSION} for ${HOST_OS}."
}

getHelm::init

