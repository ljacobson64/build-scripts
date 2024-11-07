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
setup_string_1+=" --no_spatial_solvers"
setup_string_2+=" --prefix=${install_prefix}"
setup_string_2+=" -j${num_cpus}"

python setup.py ${setup_string_1} install ${setup_string_2}

PYTHONPATH=${install_prefix}/lib/python3.12/site-packages
DATAPATH=
cd ..
${install_prefix}/bin/nuc_data_make

cd ${install_prefix}
dirs="bin include lib/python3.12/site-packages"
files="lib/*.so"
for d in ${dirs}; do
  mkdir -pv ${python_dir}/${d}
  ln -svf ${install_prefix}/${d}/* ${python_dir}/${d}
done
for f in ${files}; do
  ln -svf ${install_prefix}/${f} ${python_dir}/${f}
done
