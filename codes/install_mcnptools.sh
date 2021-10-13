#!/bin/bash

set -e

build_prefix=${build_dir}/MCNPTOOLS-${mcnptools_version}
install_prefix=${native_dir}/MCNPTOOLS-${mcnptools_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
unzip ${dist_dir}/mcnp/mcnptools-${mcnptools_version}.zip
ln -sv Source/libmcnptools src
cd bld

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install

cd ../Source/python

python2 setup.py build
mkdir -pv ${install_prefix}/lib/python${python2_version_major}/site-packages
PYTHONPATH=${install_prefix}/lib/python${python2_version_major}/site-packages
python2 setup.py install --prefix=${install_prefix}

python3 setup.py build
mkdir -pv ${install_prefix}/lib/python${python3_version_major}/site-packages
PYTHONPATH=${install_prefix}/lib/python${python3_version_major}/site-packages
python3 setup.py install --prefix=${install_prefix}
