#!/bin/bash

set -e

export cgm_version=16.0
export cubit_version=14.0

build_prefix=${build_dir}/cgm-${cgm_version}-cubit-${cubit_version}
install_prefix=${install_dir}/cgm-${cgm_version}-cubit-${cubit_version}

cubit_dir=${install_dir}/cubit-${cubit_version}

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
cd bld

rpath_dirs=${cubit_dir}/bin:${install_prefix}/lib
if [ -n "${compiler_rpath_dirs}" ]; then
  rpath_dirs=${compiler_rpath_dirs}:${rpath_dirs}
fi

cmake_string=
cmake_string+=" -DENABLE_CUBIT=ON"
cmake_string+=" -DCUBIT_DIR=${cubit_dir}"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string+=" -DCMAKE_INSTALL_RPATH=${rpath_dirs}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install

sed -i "s/#include \"CGMIGeomConfigure.h\"/#include \"cgm\/CGMIGeomConfigure.h\"/" ${install_prefix}/include/iGeom.h
