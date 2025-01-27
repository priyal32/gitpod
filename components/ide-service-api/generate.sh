#!/bin/bash

if [ -n "$DEBUG" ]; then
  set -x
fi

set -o errexit
set -o nounset
set -o pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/../../
COMPONENTS_DIR=$ROOT_DIR/components

# include protoc bash functions
# shellcheck disable=SC1090,SC1091
source "$ROOT_DIR"/scripts/protoc-generator.sh

# TODO (aledbf): refactor to avoid duplication
local_go_protoc() {
    local ROOT_DIR=$1
    # shellcheck disable=2035
    protoc \
        -I/usr/lib/protoc/include -I"$COMPONENTS_DIR" -I. \
        --go_out=go \
        --go_opt=paths=source_relative \
        --go-grpc_out=go \
        --go-grpc_opt=paths=source_relative \
        *.proto
}

go_protoc_gateway() {
    # shellcheck disable=2035
    protoc \
        -I/usr/lib/protoc/include -I"$COMPONENTS_DIR" -I. \
        --grpc-gateway_out=logtostderr=true,paths=source_relative:go \
        *.proto
}

install_dependencies
local_go_protoc "$COMPONENTS_DIR"
go_protoc_gateway "$COMPONENTS_DIR"
update_license
