#!/bin/bash

source versions.sh

# Important directories
export dist_dir=/groupspace/cnerg/users/jacobson/dist
export build_dir=/local.hd/cnergg/jacobson/build/${compiler}
export install_dir=/groupspace/cnerg/users/jacobson/opt/${compiler}
export native_dir=/groupspace/cnerg/users/jacobson/opt/native
export gcc_dir=${native_dir}/gcc-${gcc_version}
export intel_dir=/groupspace/cnerg/users/jacobson/intel/compilers_and_libraries_2018.3.222/linux
export mcnp_exe=/groupspace/cnerg/users/jacobson/MCNP/MCNP_CODE/bin/mcnp5
export DATAPATH=/groupspace/cnerg/users/jacobson/MCNP/MCNP_DATA
export scale_data_dir=/groupspace/cnerg/users/jacobson/SCALE/data
export lapack_dir=/usr/lib

# Miscellaneous environment variables used by install scripts
export jobs=`grep -c processor /proc/cpuinfo`
export sudo_cmd=
export slurm_support=false
export geany_needs_intltool=true
export geant4_libdir=lib
export native_python=true
export native_setuptools=true
export native_pythonpacks=false
export native_exnihilo_packs=false

# Specify location of CMake
export PATH=${native_dir}/cmake-current/bin:${PATH}
export CMAKE=${native_dir}/cmake-current/bin/cmake

# Specify paths to compilers
if [ "${compiler}" == "native" ]; then
  export CC=/usr/bin/gcc
  export CXX=/usr/bin/g++
  export FC=/usr/bin/gfortran
  export compiler_lib_dirs=
elif [ "${compiler}" == "gcc-7" ]; then
  export CC=${gcc_dir}/bin/gcc
  export CXX=${gcc_dir}/bin/g++
  export FC=${gcc_dir}/bin/gfortran
  export compiler_lib_dirs=${gcc_dir}/lib64
elif [ "${compiler}" == "intel-18" ]; then
  export CC=${intel_dir}/bin/intel64/icc
  export CXX=${intel_dir}/bin/intel64/icpc
  export FC=${intel_dir}/bin/intel64/ifort
  export compiler_lib_dirs=${intel_dir}/compiler/lib/intel64
elif [ "${compiler}" == "custom" ]; then
  export CC=${gcc_dir}/bin/gcc
  export CXX=${gcc_dir}/bin/g++
  export FC=${intel_dir}/bin/intel64/ifort
  export compiler_lib_dirs=${gcc_dir}/lib64:${intel_dir}/compiler/lib/intel64
fi

# Control which versions of MCNP/DAGMC are built
if [ "${compiler}" == "native" ]; then
  export install_mcnpx27=true
  export install_fludag=false
  export install_daggeant4=true
elif [ "${compiler}" == "gcc-7" ]; then
  export install_mcnpx27=true
  export install_fludag=true
  export install_daggeant4=true
elif [ "${compiler}" == "intel-18" ]; then
  export install_mcnpx27=true
  export install_fludag=false
  export install_daggeant4=false
elif [ "${compiler}" == "custom" ]; then
  export install_mcnpx27=true
  export install_fludag=false
  export install_daggeant4=false
fi

# Set additional path environment variables
export LD_LIBRARY_PATH=
export LIBRARY_PATH=${compiler_lib_dirs}
