#!/bin/bash

set -e

build_prefix=${build_dir}/pyne-${pyne_version}
install_prefix=${install_dir}/pyne-${pyne_version}

rm -rfv   ${build_prefix}
mkdir -pv ${build_prefix}
cd        ${build_prefix}
git clone https://github.com/pyne/pyne -b ${pyne_version} --single-branch

cd pyne
sed -i "s/import imp/#import imp/" setup.py setup_sub.py

setup_string_1=
setup_string_1+=" -DCMAKE_BUILD_TYPE=Release"
setup_string_1+=" -DCMAKE_C_COMPILER=${CC}"
setup_string_1+=" -DCMAKE_CXX_COMPILER=${CXX}"
setup_string_1+=" -DCMAKE_Fortran_COMPILER=${FC}"
setup_string_2=
setup_string_2+=" --no_spatial_solvers"
setup_string_2+=" --prefix=${install_prefix}"
setup_string_2+=" -j${num_cpus}"

python3 setup.py ${setup_string_1} install ${setup_string_2}

PYTHONPATH=${install_prefix}/lib/python${python_version_major}/site-packages
DATAPATH=
cd ..
${install_prefix}/bin/nuc_data_make
