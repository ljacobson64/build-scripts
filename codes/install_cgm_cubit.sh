#!/bin/bash

set -e

build_prefix=${build_dir}/cgm-${cgm_version}
install_prefix=${install_dir}/cgm-${cgm_version}

cubit_dir=${install_dir}/cubit-${cgm_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}

tarball=cgm-${cgm_version}.tar.gz
url=https://bitbucket.org/fathomteam/cgm/get/${cgm_version}.tar.gz
if [ ! -f ${dist_dir}/sigma/${tarball} ]; then
  wget ${url} -P ${dist_dir}/sigma/
  mv -v ${dist_dir}/sigma/${cgm_version}.tar.gz ${dist_dir}/sigma/${tarball}
fi
tar -xzvf ~/dist/sigma/${tarball}
mv fathomteam-cgm-* cgm-${cgm_version}
ln -sv cgm-${cgm_version} src
cd cgm-${cgm_version}
autoreconf -fi
cd ../bld

config_string=
config_string+=" --enable-shared"
config_string+=" --enable-optimize"
config_string+=" --disable-debug"
config_string+=" --with-cubit=${cubit_dir}"
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
if [ -n "${compiler_rpath_dirs}" ]; then
  config_string+=" LDFLAGS=-Wl,-rpath,${compiler_rpath_dirs}:${cubit_dir}/bin"
else
  config_string+=" LDFLAGS=-Wl,-rpath,${cubit_dir}/bin"
fi

../src/configure ${config_string}
make -j${num_cpus}
make -j${num_cpus} install
