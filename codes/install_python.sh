#!/bin/bash

set -e

build_prefix=${build_dir}/python-${python_version}
install_prefix=${install_dir}/python-${python_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=Python-${python_version}.tgz
url=https://www.python.org/ftp/python/${python_version}/${tarball}
if [ ! -f ${dist_dir}/python/${tarball} ]; then wget ${url} -P ${dist_dir}/python/; fi
tar -xzvf ${dist_dir}/python/${tarball}
ln -sv Python-${python_version} src
cd bld

config_string=
config_string+=" --enable-shared"
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
if [ -n "${compiler_lib_dirs}" ]; then
  config_string+=" LDFLAGS=-Wl,-rpath,${compiler_lib_dirs}:${install_prefix}/lib"
else
  config_string+=" LDFLAGS=-Wl,-rpath,${install_prefix}/lib"
fi

../src/configure ${config_string}
make -j${jobs}
${sudo_cmd_install} make -j${jobs} install

if [ "${native_python}" == "true" ]; then
  exit 0
fi

export python_pip_version=20.0.2
export python_setuptools_version=46.1.3

if [ "${compiler}" != "native" ]; then
  PATH=${gcc_dir}/bin:${PATH}
fi

${sudo_cmd_install} mkdir -pv ${install_prefix}/lib/python2.7/site-packages
PATH=${install_prefix}/bin:${PATH}
PYTHONPATH=${install_prefix}/lib/python2.7/site-packages

cd ${build_prefix}
tarball=setuptools-${python_setuptools_version}.tar.gz
url=https://codeload.github.com/pypa/setuptools/tar.gz/v${python_setuptools_version}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then
  wget ${url} -P ${dist_dir}/misc/
  mv -v ${dist_dir}/misc/v${python_setuptools_version} ${dist_dir}/misc/${tarball}
fi
tar -xzvf ${dist_dir}/misc/${tarball}
cd setuptools-${python_setuptools_version}
python bootstrap.py
${sudo_cmd_install} python setup.py install --prefix=${install_prefix}

cd ${build_prefix}
tarball=pip-${python_pip_version}.tar.gz
url=https://codeload.github.com/pypa/pip/tar.gz/${python_pip_version}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then
  wget ${url} -P ${dist_dir}/misc/
  mv -v ${dist_dir}/misc/${python_pip_version} ${dist_dir}/misc/${tarball}
fi
tar -xzvf ${dist_dir}/misc/${tarball}
cd pip-${python_pip_version}
${sudo_cmd_install} python setup.py install --prefix=${install_prefix}

cd ${build_prefix}
python_packs="pip setuptools numpy scipy cython tables nose"
for pack in ${python_packs}; do
  ${sudo_cmd_install} pip install --prefix=${install_prefix} --upgrade ${pack}
done
