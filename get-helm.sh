#!/usr/bin/env bash

VERSION="$1"

if [ -z $VERSION ]; then
  echo "Please provide a valid semantic version for Helm."
  exit 1
else
  readonly VERSION="${VERSION#[Vv]}"
fi

getHelm::genConfig(){
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
  readonly ARTIFACT="helm-v${VERSION}-${HOST_OS}-${ARCH}.${EXT}"
  readonly ARTIFACT_SHA="${ARTIFACT}.sha256"
  readonly ARTIFACTS_ENDPOINT="https://get.helm.sh"
}

getHelm::genSHA256(){
  local file
  file="$1"
  if [ "$HOST_OS" -eq "windows" ]; then
    echo "$(sha265sum.exe "$file" | awk '{ printf $1 }')"
  else
    echo "$(sha256sum "$file" | awk '{ printf $1 }')"
  fi
}

getHelm::genHelmDir(){
  local helm_directory="./bin/helm"
  if ! mkdir -p "$helm_directory" > /dev/null 2>&1; then
    return 1
  fi
}

getHelm::downloadArtifact(){
  if ! curl -sO "$ARTIFACTS_ENDPOINT/${ARTIFACT}" > /dev/null 2>&1; then
    return 1
  fi
}

getHelm::downloadArtifactSHA(){
  if ! curl -sO "${ARTIFACTS_ENDPOINT}/${ARTIFACT_SHA}" > /dev/null 2>&1; then
    return 1
  fi
}

getHelm::extractArtifact(){
  local file="$1"
  if [ "$HOST_OS" -eq "windows" ]; then
    unzip "$file" > /dev/null 2>&1
  else
    tar -xvf "$file" > /dev/null 2>&1
  fi
}

getHelm::artifactExists(){
  file="$1"
  if [ ! -f "$file" ]; then
    return 1
  fi
}

getHelm::init(){
  if ! getHelm::genConfig; then
    echo "Could not determine your operating system. Aborting."
    exit 1
  fi

  if ! getHelm::genHelmBin

  if ! getHelm::downloadArtifact; then
    echo "Unable to download package for Helm v${VERSION}. Aborting."
    exit 1
  fi  
  
  if ! getHelm::downloadArtifactSHA; then
    echo "Unable to download the SHA for Helm v${VERSION}. Aborting."
    exit 1
  fi
  
  if ! getHelm::artfactExists; then
    echo "Could not locate Helm package. Aboirting."
    exit 1
  fi

}

getHelm::init

