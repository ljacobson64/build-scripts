#!/bin/bash

set -e

build_prefix=${build_dir}/pyne
install_prefix=${install_dir}/pyne

hdf5_dir=${install_dir}/hdf5-${hdf5_version}
moab_dir=${install_dir}/moab-${moab_version}
dagmc_dir=${install_dir}/DAGMC-moab-${moab_version}

if [ "${compiler}" != "native" ]; then
  PATH=${gcc_dir}/bin:${PATH}
fi

if [ "${native_python}" == "false" ]; then
  python_dir=${install_dir}/python-${python3_version}
  PATH=${python_dir}/bin:${PATH}
  PYTHONPATH=${python_dir}/lib/python3.8/site-packages
fi

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}
${sudo_cmd_install} mkdir -pv ${install_prefix}/lib/python3.8/site-packages

PATH=${hdf5_dir}/bin:${PATH}
PATH=${moab_dir}/bin:${PATH}
PATH=${install_prefix}/bin:${PATH}
PYTHONPATH=${install_prefix}/lib/python3.8/site-packages:${PYTHONPATH}

cd ${build_prefix}
git clone https://github.com/pyne/pyne -b develop --single-branch
cd pyne
sed -i "s/pyne_configure_rpath()/#pyne_configure_rpath()/" CMakeLists.txt

setup_string_1=
setup_string_1+=" -DCMAKE_BUILD_TYPE=Release"
setup_string_1+=" -DCMAKE_C_COMPILER=${CC}"
setup_string_1+=" -DCMAKE_CXX_COMPILER=${CXX}"
setup_string_1+=" -DCMAKE_Fortran_COMPILER=${FC}"
if [ -n "${compiler_lib_dirs}" ]; then
  setup_string_1+=" -DCMAKE_INSTALL_RPATH=${compiler_lib_dirs}:${hdf5_dir}/lib:${moab_dir}/lib:${dagmc_dir}/lib"
else
  setup_string_1+=" -DCMAKE_INSTALL_RPATH=${hdf5_dir}/lib:${moab_dir}/lib:${dagmc_dir}/lib"
fi
setup_string_2=
setup_string_2+=" --hdf5=${hdf5_dir}"
setup_string_2+=" --moab=${moab_dir}"
setup_string_2+=" --dagmc=${dagmc_dir}"
setup_string_2+=" --prefix=${install_prefix}"
setup_string_2+=" -j${num_cpus}"

${sudo_cmd_install} python3 setup.py ${setup_string_1} install ${setup_string_2}
cd ..

if [ -z "${sudo_cmd_install}" ]; then
  LD_LIBRARY_PATH=${install_prefix}/lib:${LD_LIBRARY_PATH}
  ${sudo_cmd_install} nuc_data_make
else
  export install_prefix
  ${sudo_cmd_install} --preserve-env=install_prefix sh -c '
  export PATH=${install_prefix}/bin:${PATH}
  export PYTHONPATH=${install_prefix}/lib/python3.8/site-packages:${PYTHONPATH}
  export LD_LIBRARY_PATH=${install_prefix}/lib:${LD_LIBRARY_PATH}
  nuc_data_make'
fi
