#!/bin/bash

set -e

export pyne_pip_version=18.1
export pyne_setuptools_version=40.6.3

build_prefix=${build_dir}/pyne
install_prefix=${install_dir}/pyne

hdf5_dir=${install_dir}/hdf5-${hdf5_version}
moab_dir=${install_dir}/moab-${moab_version}
dagmc_dir=${install_dir}/DAGMC-moab-${moab_version}

if [ "${compiler}" != "native" ]; then
  PATH=${gcc_dir}/bin:${PATH}
fi

if [ "${native_python}" != "true" ]; then
  python_dir=${install_dir}/python-${python_version}
  PATH=${python_dir}/bin:${PATH}
fi

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}
${sudo_cmd_install} mkdir -pv ${install_prefix}/lib/python2.7/site-packages

PATH=${hdf5_dir}/bin:${PATH}
PATH=${moab_dir}/bin:${PATH}
PATH=${install_prefix}/bin:${PATH}
PYTHONPATH=${install_prefix}/lib/python2.7/site-packages

# Setuptools
if [ "${native_python}" != "true" ]; then
  cd ${build_prefix}
  tarball=setuptools-${pyne_setuptools_version}.tar.gz
  url=https://codeload.github.com/pypa/setuptools/tar.gz/v${pyne_setuptools_version}
  if [ ! -f ${dist_dir}/misc/${tarball} ]; then
    wget ${url} -P ${dist_dir}/misc/
    mv -v ${dist_dir}/misc/v${pyne_setuptools_version} ${dist_dir}/misc/${tarball}
  fi
  tar -xzvf ${dist_dir}/misc/${tarball}
  cd setuptools-${pyne_setuptools_version}
  python bootstrap.py
  ${sudo_cmd_install} python setup.py install --prefix=${python_dir}
fi

# Pip
if [ "${native_python}" != "true" ]; then
  cd ${build_prefix}
  tarball=pip-${pyne_pip_version}.tar.gz
  url=https://codeload.github.com/pypa/pip/tar.gz/${pyne_pip_version}
  if [ ! -f ${dist_dir}/misc/${tarball} ]; then
    wget ${url} -P ${dist_dir}/misc/
    mv -v ${dist_dir}/misc/${pyne_pip_version} ${dist_dir}/misc/${tarball}
  fi
  tar -xzvf ${dist_dir}/misc/${tarball}
  cd pip-${pyne_pip_version}
  ${sudo_cmd_install} python setup.py install --prefix=${python_dir}
fi

# Other python packages
HDF5_DIR=${hdf5_dir}
if [ "${native_python}" != "true" ]; then
  ${sudo_cmd_install} pip install --prefix=${python_dir} --ignore-installed --upgrade pip
  ${sudo_cmd_install} pip install --prefix=${python_dir} --ignore-installed --upgrade setuptools
  ${sudo_cmd_install} pip install --prefix=${python_dir} --ignore-installed --upgrade numpy
  ${sudo_cmd_install} pip install --prefix=${python_dir} --ignore-installed --upgrade scipy
  ${sudo_cmd_install} pip install --prefix=${python_dir} --ignore-installed --upgrade cython
  ${sudo_cmd_install} pip install --prefix=${python_dir} --ignore-installed --upgrade tables
  ${sudo_cmd_install} pip install --prefix=${python_dir} --ignore-installed --upgrade nose
fi

# pyne
cd ${build_prefix}
git clone https://github.com/ljacobson64/pyne -b pymoab_cleanup --single-branch
cd pyne
sed -i "s/pyne_configure_rpath()/#pyne_configure_rpath()/" CMakeLists.txt

setup_string_1=
setup_string_1+=" -DCMAKE_BUILD_TYPE=Release"
setup_string_1+=" -DCMAKE_C_COMPILER=${CC}"
setup_string_1+=" -DCMAKE_CXX_COMPILER=${CXX}"
setup_string_1+=" -DCMAKE_Fortran_COMPILER=${FC}"
setup_string_1+=" -DCMAKE_INSTALL_RPATH=${compiler_lib_dirs}:${hdf5_dir}/lib:${moab_dir}/lib:${dagmc_dir}/lib"
setup_string_2=
setup_string_2+=" --hdf5=${hdf5_dir}"
setup_string_2+=" --moab=${moab_dir}"
setup_string_2+=" --dagmc=${dagmc_dir}"
setup_string_2+=" --prefix=${install_prefix}"
setup_string_2+=" -j${jobs}"

${sudo_cmd_install} python setup.py ${setup_string_1} install ${setup_string_2}
cd ..
LD_LIBRARY_PATH=${install_prefix}/lib:${LD_LIBRARY_PATH}
${sudo_cmd_install} nuc_data_make
