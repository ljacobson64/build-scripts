#!/bin/bash

set -e

export cgm_version=16.0

build_prefix=${build_dir}/cgm-${cgm_version}-oce-${oce_version}
install_prefix=${install_dir}/cgm-${cgm_version}-oce-${oce_version}

oce_dir=${native_dir}/oce-${oce_version}

repo=https://bitbucket.org/fathomteam/cgm
branch=master

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
git clone ${repo} -b ${branch} --single-branch
ln -sv cgm src
cd bld

cmake_string=
cmake_string+=" -DENABLE_OCC=ON"
cmake_string+=" -DOCC_DIR=${oce_dir}"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string+=" -DCMAKE_INSTALL_RPATH=${compiler_lib_dirs}:${oce_dir}/lib:${install_prefix}/lib"

cmake ../src ${cmake_string}
make -j${jobs}
${sudo_cmd} make install
