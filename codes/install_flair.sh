#!/bin/bash

set -e

build_prefix=${build_dir}/flair-${flair_version}
install_prefix=${install_dir}/flair-${flair_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}
cd ${build_prefix}
tarball=flair-${flair_version}.tgz
url=https://flair.web.cern.ch/flair/download/${tarball}
if [ ! -f ${dist_dir}/fluka/${tarball} ]; then wget ${url} -P ${dist_dir}/fluka/; fi
tar -xzvf ${dist_dir}/fluka/${tarball}
flair_version_major=$(echo ${flair_version} | cut -f1 -d'-')
cd flair-${flair_version_major}

make -j${num_cpus}
make -j${num_cpus} install DESTDIR=${install_prefix}

cd ..
tarball=flair-geoviewer-${flair_version}.tgz
url=https://flair.web.cern.ch/flair/download/${tarball}
if [ ! -f ${dist_dir}/fluka/${tarball} ]; then wget ${url} -P ${dist_dir}/fluka/; fi
tar -xzvf ${dist_dir}/fluka/${tarball}
cd flair-geoviewer-${flair_version_major}

make -j${num_cpus}
make -j${num_cpus} install DESTDIR=${install_prefix}
