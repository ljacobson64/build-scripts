#!/bin/bash

set -e

build_prefix=${build_dir}/moab-${moab_version}
install_prefix=${install_dir}/moab-${moab_version}
if [ "${compiler}" == "intel" ]; then
  build_prefix+=-intel
  install_prefix+=-intel
fi

if [ "${install_pymoab}" == "true" ] && [ "${custom_python}" == "true" ]; then
  load_python3
fi

eigen_dir=${install_dir}/eigen-${eigen_version}
hdf5_dir=${install_dir}/hdf5-${hdf5_version}
if [ "${compiler}" == "intel" ]; then
  hdf5_dir+=-intel
fi

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=moab-${moab_version}.tar.gz
url=https://bitbucket.org/fathomteam/moab/get/${moab_version}.tar.gz
if [ ! -f ${dist_dir}/sigma/${tarball} ]; then
  wget ${url} -P ${dist_dir}/sigma/
  mv -v ${dist_dir}/sigma/${moab_version}.tar.gz ${dist_dir}/sigma/${tarball}
fi
tar -xzvf ~/dist/sigma/${tarball}
mv fathomteam-moab-* moab-${moab_version}
ln -sv moab-${moab_version} src
cd moab-${moab_version}
autoreconf -fi
if [[ "${moab_version}" == "4"* ]]; then
  sed -i "s/HUGE/HUGE_VAL/" src/LocalDiscretization/LinearTet.cpp
  sed -i "s/HUGE/HUGE_VAL/" src/LocalDiscretization/LinearTri.cpp
fi
cd ../bld

if [[ "${moab_version}" == "5"* ]] && [ "$(basename $FC)" != "ifort" ]; then
  install_pymoab=true
else
  install_pymoab=false
fi

rpath_dirs=${hdf5_dir}/lib
if [ -n "${compiler_rpath_dirs}" ]; then
  rpath_dirs=${compiler_rpath_dirs}:${rpath_dirs}
fi

config_string=
if [[ "${moab_version}" == "4"* ]]; then
  config_string+=" --enable-dagmc"
fi
if [ "${install_pymoab}" == "true" ]; then
  config_string+=" --enable-pymoab"
fi
config_string+=" --enable-shared"
config_string+=" --enable-optimize"
config_string+=" --disable-debug"
config_string+=" --disable-blaslapack"
if [ "${custom_eigen}" == "true" ]; then
  config_string+=" --with-eigen3=${eigen_dir}/include/eigen3"
fi
config_string+=" --with-hdf5=${hdf5_dir}"
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
if [ "${install_pymoab}" == "true" ] && [ "${custom_python}" == "true" ]; then
  config_string+=" PYTHON=${python3_dir}/bin/python3"
fi
config_string+=" LDFLAGS=-Wl,-rpath,${rpath_dirs}"

../src/configure ${config_string}
make -j${num_cpus}
make install
