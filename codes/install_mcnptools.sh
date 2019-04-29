#!/bin/bash

set -e

build_prefix=${build_dir}/MCNPTOOLS
install_prefix=${native_dir}/MCNPTOOLS

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tar -xzvf ${dist_dir}/mcnp/mcnp620-tools.tar.gz
ln -sv MCNPTOOLS/Source/libmcnptools src
cd bld

cmake_string=
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

${CMAKE} ../src ${cmake_string}
make -j${jobs}
${sudo_cmd_native} make -j${jobs} install

cd ../MCNPTOOLS/Source/python

python setup.py build
${sudo_cmd_native} mkdir -pv ${install_prefix}/lib/python2.7/site-packages
PYTHONPATH=${install_prefix}/lib/python2.7/site-packages
${sudo_cmd_native} PYTHONPATH=${PYTHONPATH} python setup.py install --prefix=${install_prefix}

python3 setup.py build
${sudo_cmd_native} mkdir -pv ${install_prefix}/lib/python3.6/site-packages
PYTHONPATH=${install_prefix}/lib/python3.6/site-packages
${sudo_cmd_native} PYTHONPATH=${PYTHONPATH} python3 setup.py install --prefix=${install_prefix}
