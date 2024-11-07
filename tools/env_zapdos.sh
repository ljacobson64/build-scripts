#!/bin/bash

source versions.sh

# Make sure this stuff is blank
export LD_LIBRARY_PATH=
export LIBRARY_PATH=

# Important directories
export    dist_dir=/home/lucas/dist
export   build_dir=/home/lucas/build
export install_dir=/opt/software
export  python_dir=/opt/software/python-3.12

# Miscellaneous environment variables
export num_cpus=`grep -c processor /proc/cpuinfo`

# Specify location of CMake
export CMAKE=/usr/bin/cmake

# Specify paths to compilers
if [ "${compiler}" == "native" ]; then
  export     CC=/usr/bin/gcc
  export    CXX=/usr/bin/g++
  export     FC=/usr/bin/gfortran
  export compiler_rpath_dirs=
elif [ "${compiler}" == "intel" ]; then
  source /opt/intel/oneapi/setvars.sh
  export intel_dir=/opt/intel/oneapi/compiler/2023.2.4/linux
  export  CC=${intel_dir}/bin/icx
  export CXX=${intel_dir}/bin/icpx
  export  FC=${intel_dir}/bin/ifx
  export compiler_rpath_dirs=${intel_dir}/compiler/lib/intel64
  export LD_LIBRARY_PATH=${compiler_rpath_dirs}
fi
