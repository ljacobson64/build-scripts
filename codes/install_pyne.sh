#!/bin/bash

set -e

build_prefix=${build_dir}/pyne
install_prefix=${install_dir}/pyne

if [ "${custom_python}" == "true" ]; then
  load_python3
fi

lapack_dir=${install_dir}/lapack-${lapack_version}
hdf5_dir=${install_dir}/hdf5-${hdf5_version}
moab_dir=${install_dir}/moab-${moab_version}
dagmc_dir=${install_dir}/DAGMC-moab-${moab_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}
cd ${build_prefix}
git clone https://github.com/pyne/pyne -b develop --single-branch
cd pyne
sed -i "s/pyne_configure_rpath()/#pyne_configure_rpath()/" CMakeLists.txt

rpath_dirs=${hdf5_dir}/lib:${moab_dir}/lib:${dagmc_dir}/lib
if [ "${custom_lapack}" == "true" ]; then
  rpath_dirs=${lapack_dir}/lib64:${rpath_dirs}
fi
if [ -n "${compiler_rpath_dirs}" ]; then
  rpath_dirs=${compiler_rpath_dirs}:${rpath_dirs}
fi

setup_string_1=
setup_string_1+=" -DCMAKE_BUILD_TYPE=Release"
setup_string_1+=" -DCMAKE_C_COMPILER=${CC}"
setup_string_1+=" -DCMAKE_CXX_COMPILER=${CXX}"
setup_string_1+=" -DCMAKE_Fortran_COMPILER=${FC}"
if [ "${custom_lapack}" == "true" ]; then
  setup_string_1+=" -DCMAKE_PREFIX_PATH=${lapack_dir}"
fi
setup_string_1+=" -DCMAKE_INSTALL_RPATH=${rpath_dirs}"
setup_string_2=
setup_string_2+=" --hdf5=${hdf5_dir}"
setup_string_2+=" --moab=${moab_dir}"
setup_string_2+=" --dagmc=${dagmc_dir}"
setup_string_2+=" --prefix=${install_prefix}"
setup_string_2+=" -j${num_cpus}"

mkdir -pv ${install_prefix}/lib/python${python3_version_major}/site-packages

PYTHONPATH=${install_prefix}/lib/python${python3_version_major}/site-packages:${PYTHONPATH}

python3 setup.py ${setup_string_1} install ${setup_string_2}

LD_LIBRARY_PATH=${install_prefix}/lib:${LD_LIBRARY_PATH}

scripts/nuc_data_make
