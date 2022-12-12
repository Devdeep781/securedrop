#!/bin/bash
# shellcheck disable=SC2209

export OSSEC_VERSION="3.6.0"

set -euxo pipefail

cd /srv
# Download the source and signature
curl -L https://github.com/ossec/ossec-hids/archive/refs/tags/${OSSEC_VERSION}.tar.gz \
    -o ossec-hids-${OSSEC_VERSION}.tar.gz
curl -L https://github.com/ossec/ossec-hids/releases/download/${OSSEC_VERSION}/ossec-hids-${OSSEC_VERSION}.tar.gz.asc -O
gpgv --keyring /ossec.gpg ossec-hids-${OSSEC_VERSION}.tar.gz.asc ossec-hids-${OSSEC_VERSION}.tar.gz
rm ossec-hids-${OSSEC_VERSION}.tar.gz.asc

tar xvzf ossec-hids-${OSSEC_VERSION}.tar.gz
cd ossec-hids-${OSSEC_VERSION}
cp -Rv /src/devops/packaging/ossec-"${VARIANT}"/debian debian

# Build the package
dpkg-buildpackage -us -uc

# Copy the built artifacts back and print checksums
mv -v ../*.{buildinfo,changes,deb,tar.gz} /src/build/
cd /src/build/
sha256sum ./*
