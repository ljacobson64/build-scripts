#!/bin/bash

set -e

pip_version=9.0.3
setuptools_version=39.0.1

build_prefix=${build_dir}/pyne
install_prefix=${install_dir}/pyne

if false; then
  python_dir=${install_dir}/python-${python_version}
  PATH=${python_dir}/bin:${PATH}
fi

rm -rf ${build_prefix}
mkdir -p ${build_prefix}
${sudo_cmd} mkdir -p ${install_prefix}/lib/python2.7/site-packages
PYTHONPATH=${install_prefix}/lib/python2.7/site-packages

# Setuptools
if false; then
  cd ${build_prefix}
  tarball=setuptools-${setuptools_version}.tar.gz
  url=https://codeload.github.com/pypa/setuptools/tar.gz/v${setuptools_version}
  if [ ! -f ${dist_dir}/misc/${tarball} ]; then
    wget ${url} -P ${dist_dir}/misc/
    mv ${dist_dir}/misc/v${setuptools_version} ${dist_dir}/misc/${tarball}
  fi
  tar -xzvf ${dist_dir}/misc/${tarball}
  cd setuptools-${setuptools_version}
  python bootstrap.py
  ${sudo_cmd} python setup.py install --prefix=${install_prefix}
fi

# Pip
cd ${build_prefix}
tarball=pip-${pip_version}.tar.gz
url=https://codeload.github.com/pypa/pip/tar.gz/${pip_version}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then
  wget ${url} -P ${dist_dir}/misc/
  mv ${dist_dir}/misc/${pip_version} ${dist_dir}/misc/${tarball}
fi
tar -xzvf ${dist_dir}/misc/${tarball}
cd pip-${pip_version}
${sudo_cmd} python setup.py install --prefix=${install_prefix}
PATH=${install_prefix}/bin:${PATH}

# Other python packages
${sudo_cmd} pip install --prefix=${install_prefix} --ignore-installed --upgrade pip
${sudo_cmd} pip install --prefix=${install_prefix} --ignore-installed --upgrade setuptools
${sudo_cmd} pip install --prefix=${install_prefix} --ignore-installed --upgrade numpy
${sudo_cmd} pip install --prefix=${install_prefix} --ignore-installed --upgrade scipy
${sudo_cmd} pip install --prefix=${install_prefix} --ignore-installed --upgrade cython
${sudo_cmd} pip install --prefix=${install_prefix} --ignore-installed --upgrade tables
${sudo_cmd} pip install --prefix=${install_prefix} --ignore-installed --upgrade nose

# PyTAPS
HDF5_DIR=${install_dir}/hdf5-${hdf5_version}
MOAB_DIR=${install_dir}/moab-4.9.1  # Must use version 4.9.1
PATH=${HDF5_DIR}/bin:${PATH}
PATH=${MOAB_DIR}/bin:${PATH}
${sudo_cmd} pip install --prefix=${install_prefix} --ignore-installed --upgrade pytaps

# pyne
cd ${build_prefix}
git clone https://github.com/pyne/pyne -b develop --single-branch
cd pyne
setup_string_1=
setup_string_1+=" -DCMAKE_C_COMPILER=${CC}"
setup_string_1+=" -DCMAKE_CXX_COMPILER=${CXX}"
setup_string_1+=" -DCMAKE_Fortran_COMPILER=${FC}"
setup_string_1+=" -DCMAKE_BUILD_TYPE=Release"
setup_string_2=
setup_string_2+=" --hdf5=${HDF5_DIR}"
setup_string_2+=" --moab=${MOAB_DIR}"
setup_string_2+=" --prefix=${install_prefix}"
setup_string_2+=" -j${jobs}"
${sudo_cmd} python setup.py ${setup_string_1} install ${setup_string_2}
cd ..
${sudo_cmd} nuc_data_make
