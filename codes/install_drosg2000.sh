#!/bin/bash

set -e

build_prefix=${build_dir}/DROSG2000-${drosg2000_version}
install_prefix=${native_dir}/DROSG2000-${drosg2000_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=DROSG2000-v${drosg2000_version}.zip
url=https://www-nds.iaea.org/public/libraries/drosg2000/${tarball}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
unzip ${dist_dir}/misc/${tarball}
ln -sv pentiumpro src
cd pentiumpro
mv -v neuyie/PARAM.NEU neuyie/param.neu
mv -v timrev/PARAM.NEU timrev/param.neu
mv -v whiyie/PARAM.NEU whiyie/param.neu
ln -sv ${script_dir}/codes/drosg2000/CMakeLists.txt .
cd ../bld

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

cmake ../src ${cmake_string}
make -j${jobs}
${sudo_cmd_install} make -j${jobs} install
