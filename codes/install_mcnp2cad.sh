#!/bin/bash

set -e

if [[ "${mcnp2cad_version}" == *"cgm-"* ]]; then
  cgm_version=$(cut -d '-' -f2  <<< "${mcnp2cad_version}")
  mcnp2cad_version=
fi

build_prefix=${build_dir}/mcnp2cad-cgm-${cgm_version}
install_prefix=${install_dir}/mcnp2cad-cgm-${cgm_version}

armadillo_dir=${install_dir}/armadillo-${armadillo_version}
cubit_dir=${native_dir}/cubit-${cgm_version}
cgm_dir=${install_dir}/cgm-${cgm_version}

if [ "${cgm_version}" == "14.0" ]; then
  branch=sns_gq_updates
else
  branch=master
fi

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}
cd ${build_prefix}
git clone https://github.com/svalinn/mcnp2cad -b ${branch} --single-branch
cd mcnp2cad
sed -i 's/LDFLAGS = ${IGEOM_LIBS}/LDFLAGS += ${IGEOM_LIBS}/' Makefile

make_string=
if [ ! -f /usr/lib/libarmadillo.so ]; then
  make_string+=" ARMADILLO_BASE_DIR=${armadillo_dir}"
fi
make_string+=" CGM_BASE_DIR=${cgm_dir}"
make_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
make_string_pre="LDFLAGS=-Wl,-rpath,${compiler_lib_dirs}:${cubit_dir}/bin:${cgm_dir}/lib"

eval ${make_string_pre} make -j${jobs} ${make_string}
${sudo_cmd} mkdir -pv ${install_prefix}/bin
${sudo_cmd} cp -pv mcnp2cad ${install_prefix}/bin
