#!/bin/bash
# shellcheck disable=SC2209
#
# Wrapper around debian build logic to bootstrap virtualenv

set -euxo pipefail

USE_PODMAN="${USE_PODMAN:-}"

# Allow opting into using podman with USE_PODMAN=1
if  [[ -n "${USE_PODMAN}" ]]; then
    DOCKER_BIN="podman"
else
    DOCKER_BIN="docker"
fi

cd "$(git rev-parse --show-toplevel)"

. ./devops/packaging/image_prep.sh

BUILD="${BUILD:-securedrop}"


if [[ $BUILD == "ossec" ]]; then
    $DOCKER_BIN run --rm -it -v "$(pwd)":/src -e VARIANT=agent --entrypoint "/build-debs-ossec" fpf.local/sd-server-builder
    $DOCKER_BIN run --rm -it -v "$(pwd)":/src -e VARIANT=server --entrypoint "/build-debs-ossec" fpf.local/sd-server-builder
else
    $DOCKER_BIN run --rm -it -v "$(pwd)":/src --entrypoint "/build-debs-securedrop" fpf.local/sd-server-builder
fi

NOTEST="${NOTEST:-}"

if [[ $NOTEST == "" ]]; then
    . ./devops/scripts/boot-strap-venv.sh
    virtualenv_bootstrap

    if [[ $BUILD == "ossec" ]]; then
        pytest -v devops/packaging/tests/test_ossec_package.py
    else
        pytest -v devops/packaging/tests/test_securedrop_deb_package.py
    fi
fi
