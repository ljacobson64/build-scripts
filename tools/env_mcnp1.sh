#!/bin/bash

source versions.sh

export jobs=`grep -c processor /proc/cpuinfo`
export SUDO=sudo

export dist_dir=/NV/jacobson/dist
export build_dir=/home/jacobson/build/${compiler}
export install_dir=/compute_dir/opt/${compiler}
export python_dir=/compute_dir/local
export mcnp_exe=/compute_dir/MCNP/MCNP_CODE/bin/mcnp5
export DATAPATH=/compute_dir/MCNP/MCNP_DATA

export LD_LIBRARY_PATH=
export PYTHONPATH=${python_dir}/lib/python2.7/site-packages

if [ "${compiler}" == "intel-18" ] || [ "${compiler}" == "custom" ]; then
  export intel_dir=/compute_dir/intel/compilers_and_libraries_2018.1.163/linux
  export PATH=${intel_dir}/bin/intel64:${PATH}
  export LD_LIBRARY_PATH=${intel_dir}/compiler/lib/intel64:${LD_LIBRARY_PATH}
  export CMAKE_INSTALL_RPATH_DIRS=${intel_dir}/compiler/lib/intel64;${CMAKE_INSTALL_RPATH_DIRS}
  export LDFLAGS="-Wl,-rpath,${intel_dir}/compiler/lib/intel64 ${LDFLAGS}"
fi

if [ "${compiler}" == "native" ]; then
  export CC=/usr/bin/gcc
  export CXX=/usr/bin/g++
  export FC=/usr/bin/gfortran
elif [ "${compiler}" == "intel-18" ]; then
  export CC=${intel_dir}/bin/intel64/icc
  export CXX=${intel_dir}/bin/intel64/icpc
  export FC=${intel_dir}/bin/intel64/ifort
elif [ "${compiler}" == "custom" ]; then
  export CC=/usr/bin/gcc
  export CXX=/usr/bin/g++
  export FC=${intel_dir}/bin/intel64/ifort
fi
