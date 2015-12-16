#!/bin/sh -e

if [ $(find /src -maxdepth 0 -type d -empty 2>/dev/null) ]; then
    echo "ERROR: must mount source to /src"
    exit 1
fi

canonicalname="$(go list -e -f '{{.ImportComment}}' 2>/dev/null || true)"

if [ -z "${canonicalname}" ]; then
    echo "ERROR: must add canonical import path to root package"
    echo 'Example: package main // import "github.com/org/repo"'
    exit 1
fi

# first path in GOPATH 
rootpath="${GOPATH%%:*}"

destination="${rootpath}/src/${canonicalname}"

mkdir -p "$(dirname ${destination})"

ln -sf /src "${destination}"



echo "Building ${canonicalname}"

if [ -e "${destination}/Godeps/_workspace" ]; then
    export GOPATH=${destination}/Godeps/_workspace:${GOPATH}
fi

if [ -e "${destination}/vendor" ]; then
    export GO15VENDOREXPERIMENT=1
fi

export CGO_ENABLED=0

go build -a ${canonicalname}

if [ -e "/var/run/docker.sock" ] && [ -e "./Dockerfile" ]; then
    tagname=${1:-${canonicalname##*/}:latest}

    echo "Building docker image ${tagname}"
    docker build -t ${tagname} .
fi
