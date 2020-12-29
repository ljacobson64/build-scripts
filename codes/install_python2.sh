#!/bin/bash

set -e

build_prefix=${build_dir}/python-${python2_version}
install_prefix=${install_dir}/python-${python2_version}

load_python2

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=Python-${python2_version}.tgz
url=https://www.python.org/ftp/python/${python2_version}/${tarball}
if [ ! -f ${dist_dir}/python/${tarball} ]; then wget ${url} -P ${dist_dir}/python/; fi
tar -xzvf ${dist_dir}/python/${tarball}
ln -sv Python-${python2_version} src
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

export python_pip_version=20.2.3
export python_setuptools_version=41.3.0

${sudo_cmd_install} mkdir -pv ${install_prefix}/lib/python${python2_version_major}/site-packages

cd ${build_prefix}
tarball=setuptools-${python_setuptools_version}.tar.gz
url=https://codeload.github.com/pypa/setuptools/tar.gz/v${python_setuptools_version}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then
  wget ${url} -P ${dist_dir}/misc/
  mv -v ${dist_dir}/misc/v${python_setuptools_version} ${dist_dir}/misc/${tarball}
fi
tar -xzvf ${dist_dir}/misc/${tarball}
cd setuptools-${python_setuptools_version}
python2 bootstrap.py
${sudo_cmd_install} python2 setup.py install --prefix=${install_prefix}

cd ${build_prefix}
tarball=pip-${python_pip_version}.tar.gz
url=https://codeload.github.com/pypa/pip/tar.gz/${python_pip_version}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then
  wget ${url} -P ${dist_dir}/misc/
  mv -v ${dist_dir}/misc/${python_pip_version} ${dist_dir}/misc/${tarball}
fi
tar -xzvf ${dist_dir}/misc/${tarball}
cd pip-${python_pip_version}
${sudo_cmd_install} python2 setup.py install --prefix=${install_prefix}

cd ${build_prefix}
python_packs="pip setuptools numpy scipy cython tables nose"
for pack in ${python_packs}; do
  ${sudo_cmd_install} pip2 install --prefix=${install_prefix} --upgrade ${pack}
done
