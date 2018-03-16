#!/bin/bash

set -e

build_prefix=${build_dir}/setuptools-${setuptools_version}
install_prefix=${install_dir}/setuptools-${setuptools_version}

rm -rf ${build_prefix}
mkdir -p ${build_prefix}
cd ${build_prefix}
tarball=setuptools-${setuptools_version}.tar.gz
url=https://github.com/pypa/setuptools/archive/v${setuptools_version}.tar.gz
if [ ! -f ${dist_dir}/misc/${tarball} ]; then
  wget ${url} -P ${dist_dir}/misc/
  mv ${dist_dir}/misc/v${setuptools_version}.tar.gz ${dist_dir}/misc/${tarball}
fi
tar -xzvf ${dist_dir}/misc/${tarball}
cd setuptools-${setuptools_version}

#python setup.py install --user

mkdir -p ${python_dir}/lib/python2.7/site-packages
python bootstrap.py
python setup.py install --prefix=${python_dir}
