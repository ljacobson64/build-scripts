#!/bin/bash

set -e

build_prefix=${build_dir}/python-${python3_version}
install_prefix=${install_dir}/python-${python3_version}

load_python3

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
if [ -n "${compiler_rpath_dirs}" ]; then
  config_string+=" LDFLAGS=-Wl,-rpath,${compiler_rpath_dirs}:${install_prefix}/lib"
else
  config_string+=" LDFLAGS=-Wl,-rpath,${install_prefix}/lib"
fi

../src/configure ${config_string}
make -j${num_cpus}
${sudo_cmd_install} make -j${num_cpus} install

if [ "${custom_python}" == "false" ]; then
  exit 0
fi

cd ${build_prefix}
python_packs="pip setuptools numpy scipy cython tables nose"
for pack in ${python_packs}; do
  ${sudo_cmd_install} pip3 install --prefix=${install_prefix} --upgrade ${pack}
done
