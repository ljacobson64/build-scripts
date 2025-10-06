#!/bin/bash

set -e

build_prefix=${build_dir}/MCNPTOOLS-${mcnptools_version}
install_prefix=${install_dir}/MCNPTOOLS-${mcnptools_version}

rm -rfv   ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd        ${build_prefix}
tarball=mcnptools-${mcnptools_version}.tar.gz
url=https://github.com/lanl/mcnptools/archive/refs/tags/v${mcnptools_version}.tar.gz
if [ ! -f ${dist_dir}/${tarball} ]; then
  wget ${url} -P ${dist_dir}/
  mv -v ${dist_dir}/v${mcnptools_version}.tar.gz ${dist_dir}/${tarball}
fi
tar -xzvf ${dist_dir}/${tarball}
ln -sv mcnptools-${mcnptools_version} src
cd bld

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -Dmcnptools.python_install=Prefix"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install

cd ${install_prefix}
dirs="bin include lib/cmake lib/pkgconfig lib/python3.12/site-packages share/cmake"
files="lib/*.a"
for d in ${dirs}; do
  mkdir -pv ${python_dir}/${d}
  ln -svf ${install_prefix}/${d}/* ${python_dir}/${d}
done
for f in ${files}; do
  ln -svf ${install_prefix}/${f} ${python_dir}/${f}
done
