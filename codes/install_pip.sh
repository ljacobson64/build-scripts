#!/bin/bash

set -e

build_prefix=${build_dir}/pip-${pip_version}
install_prefix=${install_dir}/pip-${pip_version}

rm -rf ${build_prefix}
mkdir -p ${build_prefix}
cd ${build_prefix}
tarball=pip-${pip_version}.tar.gz
url=https://codeload.github.com/pypa/pip/tar.gz/${pip_version}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then
  wget ${url} -P ${dist_dir}/misc/
  mv ${dist_dir}/misc/${pip_version} ${dist_dir}/misc/${tarball}
fi
tar -xzvf ${dist_dir}/misc/${tarball}
cd pip-${pip_version}

#python setup.py install --user

mkdir -p ${python_dir}/lib/python2.7/site-packages
python setup.py install --prefix=${python_dir}
