#!/bin/bash

set -e

build_prefix=${build_dir}/python-${python3_version}
install_prefix=${install_dir}/python-${python3_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=Python-${python3_version}.tgz
url=https://www.python.org/ftp/python/${python3_version}/${tarball}
if [ ! -f ${dist_dir}/python/${tarball} ]; then wget ${url} -P ${dist_dir}/python/; fi
tar -xzvf ${dist_dir}/python/${tarball}
ln -sv Python-${python3_version} src
cd bld

config_string=
config_string+=" --enable-shared"
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
config_string+=" LDFLAGS=-Wl,-rpath,${compiler_lib_dirs}:${install_prefix}/lib"

../src/configure ${config_string}
make -j${jobs}
${sudo_cmd_install} make -j${jobs} install

if [ "${native_python}" == "true" ]; then
  exit 0
fi

if [ "${compiler}" != "native" ]; then
  PATH=${gcc_dir}/bin:${PATH}
fi

PATH=${install_prefix}/bin:${PATH}
PYTHONPATH=${install_prefix}/lib/python2.7/site-packages

cd ${build_prefix}
python_packs="pip setuptools numpy scipy cython tables nose"
for pack in ${python_packs}; do
  ${sudo_cmd_install} pip3 install --prefix=${install_prefix} --upgrade ${pack}
done
