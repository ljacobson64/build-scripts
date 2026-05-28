#!/bin/bash

source versions.sh

# Make sure this stuff is blank
export LD_LIBRARY_PATH=
export LIBRARY_PATH=

# Major python version
export python_version_major=$(echo ${python_version} | cut -f1,2 -d'.')

# Important directories
export    dist_dir=/home/lucas/dist
export   build_dir=/home/lucas/build
export install_dir=/opt/software
export  python_dir=/opt/software/python-${python_version_major}

# Miscellaneous environment variables
export num_cpus=`grep -c processor /proc/cpuinfo`

# Specify location of CMake
export CMAKE=/opt/software/cmake-3.28.3/bin/cmake

# Specify paths to compilers
if [ "${compiler}" == "native" ]; then
  export gcc_dir=/opt/software/gcc-13.3.0
  export  CC=${gcc_dir}/bin/gcc
  export CXX=${gcc_dir}/bin/g++
  export  FC=${gcc_dir}/bin/gfortran
  export compiler_rpath_dirs=${gcc_dir}/lib64
  export PATH=${gcc_dir}/bin:${PATH}
  export LD_LIBRARY_PATH=${compiler_rpath_dirs}
elif [ "${compiler}" == "intel" ]; then
  source /opt/intel/oneapi/setvars.sh
  export intel_dir=/opt/intel/oneapi/compiler/2023.2.1/linux
  export  CC=${intel_dir}/bin/icx
  export CXX=${intel_dir}/bin/icpx
  export  FC=${intel_dir}/bin/ifx
  export compiler_rpath_dirs=${intel_dir}/compiler/lib/intel64
  export LD_LIBRARY_PATH=${compiler_rpath_dirs}
fi
