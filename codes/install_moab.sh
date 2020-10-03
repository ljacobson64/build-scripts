#!/bin/bash

set -e

if [[ "${moab_version}" == *"-cgm-"* ]]; then
  with_cgm=true
  cgm_version=$(cut -d '-' -f3  <<< "${moab_version}")
  moab_version=$(cut -d '-' -f1  <<< "${moab_version}")
else
  with_cgm=false
fi

if [ "${with_cgm}" == "true" ]; then
  build_prefix=${build_dir}/moab-${moab_version}-cgm-${cgm_version}
  install_prefix=${install_dir}/moab-${moab_version}-cgm-${cgm_version}
  cgm_dir=${install_dir}/cgm-${cgm_version}
else
  build_prefix=${build_dir}/moab-${moab_version}
  install_prefix=${install_dir}/moab-${moab_version}
fi

eigen_dir=${install_dir}/eigen-${eigen_version}
hdf5_dir=${install_dir}/hdf5-${hdf5_version}

if [ "${moab_version}" == "master" ]; then
  branch=master
else
  branch=Version${moab_version}
fi

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
git clone https://bitbucket.org/fathomteam/moab -b ${branch} --single-branch
ln -sv moab src
cd moab
autoreconf -fi
sed -i "s/HUGE/HUGE_VAL/" src/LocalDiscretization/LinearTet.cpp
sed -i "s/HUGE/HUGE_VAL/" src/LocalDiscretization/LinearTri.cpp
cd ../bld

if [[ "${moab_version}" == "5"* ]] && [ "$(basename $FC)" != "ifort" ]; then
  install_pymoab=true
else
  install_pymoab=false
fi

if [ -n "${compiler_lib_dirs}" ]; then
  rpath_dirs=${compiler_lib_dirs}:${hdf5_dir}/lib
else
  rpath_dirs=${hdf5_dir}/lib
fi
if [ "${with_cgm}" == "true" ]; then
  rpath_dirs+=:${cgm_dir}/lib
fi

config_string=
if [[ "${moab_version}" == "4"* ]]; then
  config_string+=" --enable-dagmc"
fi
if [ "${with_cgm}" == "true" ]; then
  config_string+=" --enable-irel"
  config_string+=" --with-cgm=${cgm_dir}"
fi
if [ "${install_pymoab}" == "true" ]; then
  config_string+=" --enable-pymoab"
fi
config_string+=" --enable-shared"
config_string+=" --enable-optimize"
config_string+=" --disable-debug"
config_string+=" --disable-blaslapack"
if [ "${native_eigen}" == "false" ]; then
  config_string+=" --with-eigen3=${eigen_dir}/include/eigen3"
fi
config_string+=" --with-hdf5=${hdf5_dir}"
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
config_string+=" LDFLAGS=-Wl,-rpath,${rpath_dirs}"

if [ "${install_pymoab}" == "true" ] && [ "${native_python}" == "false" ]; then
  PATH=${install_dir}/python-${python3_version}/bin:${PATH}
  PYTHONPATH=${install_dir}/python-${python3_version}/lib/python3.8/site-packages
fi

LD_LIBRARY_PATH=${compiler_lib_dirs}

../src/configure ${config_string}
make -j${num_cpus}
${sudo_cmd_install} make install
