#!/bin/bash

set -e

build_prefix=${build_dir}/pyne
install_prefix=${install_dir}/pyne

if [ "${compiler}" != "native" ]; then
  PATH=${gcc_dir}/bin:${PATH}
fi

if [ "${native_python}" != "true" ]; then
  python_dir=${install_dir}/python-${python_version}
  PATH=${python_dir}/bin:${PATH}
fi

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}
${sudo_cmd} mkdir -pv ${install_prefix}/lib/python2.7/site-packages

PATH=${install_prefix}/bin:${PATH}
PYTHONPATH=${install_prefix}/lib/python2.7/site-packages

# Setuptools
if [ "${native_setuptools}" != "true" ]; then
  cd ${build_prefix}
  tarball=setuptools-${setuptools_version}.tar.gz
  url=https://codeload.github.com/pypa/setuptools/tar.gz/v${setuptools_version}
  if [ ! -f ${dist_dir}/misc/${tarball} ]; then
    wget ${url} -P ${dist_dir}/misc/
    mv -v ${dist_dir}/misc/v${setuptools_version} ${dist_dir}/misc/${tarball}
  fi
  tar -xzvf ${dist_dir}/misc/${tarball}
  cd setuptools-${setuptools_version}
  python bootstrap.py
  ${sudo_cmd} python setup.py install --prefix=${install_prefix}
fi

# Pip
if [ "${native_pythonpacks}" != "true" ]; then
  cd ${build_prefix}
  tarball=pip-${pip_version}.tar.gz
  url=https://codeload.github.com/pypa/pip/tar.gz/${pip_version}
  if [ ! -f ${dist_dir}/misc/${tarball} ]; then
    wget ${url} -P ${dist_dir}/misc/
    mv -v ${dist_dir}/misc/${pip_version} ${dist_dir}/misc/${tarball}
  fi
  tar -xzvf ${dist_dir}/misc/${tarball}
  cd pip-${pip_version}
  ${sudo_cmd} python setup.py install --prefix=${install_prefix}
fi

# Other python packages
if [ "${native_pythonpacks}" != "true" ]; then
  ${sudo_cmd} pip install --prefix=${install_prefix} --ignore-installed --upgrade pip
  ${sudo_cmd} pip install --prefix=${install_prefix} --ignore-installed --upgrade setuptools
  ${sudo_cmd} pip install --prefix=${install_prefix} --ignore-installed --upgrade numpy
  ${sudo_cmd} pip install --prefix=${install_prefix} --ignore-installed --upgrade scipy
  ${sudo_cmd} pip install --prefix=${install_prefix} --ignore-installed --upgrade cython
  ${sudo_cmd} pip install --prefix=${install_prefix} --ignore-installed --upgrade tables
  ${sudo_cmd} pip install --prefix=${install_prefix} --ignore-installed --upgrade nose
fi

# On Ubuntu, ~/.config/pip/pip.conf should contain:
#
#   [install]
#   user = false

# PyTAPS
HDF5_DIR=${install_dir}/hdf5-${hdf5_version}
MOAB_DIR=${install_dir}/moab-4.9.1  # Must use version 4.9.1
PATH=${HDF5_DIR}/bin:${PATH}
PATH=${MOAB_DIR}/bin:${PATH}
${sudo_cmd} pip install --prefix=${install_prefix} --ignore-installed --no-deps --upgrade pytaps

# pyne
cd ${build_prefix}
git clone https://github.com/pyne/pyne -b develop --single-branch
cd pyne
sed -i "s/pyne_configure_rpath()/#pyne_configure_rpath()/" CMakeLists.txt

setup_string_1=
setup_string_1+=" -DCMAKE_BUILD_TYPE=Release"
setup_string_1+=" -DCMAKE_C_COMPILER=${CC}"
setup_string_1+=" -DCMAKE_CXX_COMPILER=${CXX}"
setup_string_1+=" -DCMAKE_Fortran_COMPILER=${FC}"
setup_string_1+=" -DCMAKE_INSTALL_RPATH=${compiler_lib_dirs}:${HDF5_DIR}/lib:${MOAB_DIR}/lib"
setup_string_2=
setup_string_2+=" --hdf5=${HDF5_DIR}"
setup_string_2+=" --moab=${MOAB_DIR}"
setup_string_2+=" --prefix=${install_prefix}"
setup_string_2+=" -j${jobs}"

${sudo_cmd} python setup.py ${setup_string_1} install ${setup_string_2}
cd ..
LD_LIBRARY_PATH=${install_prefix}/lib:${LD_LIBRARY_PATH}
${sudo_cmd} nuc_data_make
