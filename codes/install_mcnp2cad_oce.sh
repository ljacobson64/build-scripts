#!/bin/bash

set -e

export cgm_version=16.0

build_prefix=${build_dir}/mcnp2cad-cgm-${cgm_version}-oce-${oce_version}
install_prefix=${install_dir}/mcnp2cad-cgm-${cgm_version}-oce-${oce_version}

armadillo_dir=${install_dir}/armadillo-${armadillo_version}
oce_dir=${install_dir}/oce-${oce_version}
cgm_dir=${install_dir}/cgm-${cgm_version}-oce-${oce_version}

repo=https://github.com/svalinn/mcnp2cad
branch=master

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}
cd ${build_prefix}
git clone ${repo} -b ${branch} --single-branch
cd mcnp2cad
sed -i 's/LDFLAGS = ${IGEOM_LIBS}/LDFLAGS += ${IGEOM_LIBS}/' Makefile

make_string=
if [ ! -f /usr/lib/libarmadillo.so ]; then
  make_string+=" ARMADILLO_BASE_DIR=${armadillo_dir}"
fi
make_string+=" CGM_BASE_DIR=${cgm_dir}"
make_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
if [ -n "${compiler_rpath_dirs}" ]; then
  make_string_pre="LDFLAGS=-Wl,-rpath,${compiler_rpath_dirs}:${oce_dir}/bin:${cgm_dir}/lib"
else
  make_string_pre="LDFLAGS=-Wl,-rpath,${oce_dir}/bin:${cgm_dir}/lib"
fi

eval ${make_string_pre} make -j${num_cpus} ${make_string}
${sudo_cmd_install} mkdir -pv ${install_prefix}/bin
${sudo_cmd_install} cp -pv mcnp2cad ${install_prefix}/bin
