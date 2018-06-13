#!/bin/bash

source versions.sh

# Important directories
export dist_dir=/home/lucas/dist
export build_dir=/home/lucas/build/${compiler}
export install_dir=/home/lucas/opt/${compiler}
export native_dir=/home/lucas/opt/native
export gcc_dir=
export intel_dir=/opt/intel/compilers_and_libraries_2018.3.222/linux
export mcnp_exe=/opt/MCNP/MCNP_CODE/bin/mcnp5
export DATAPATH=/opt/MCNP/MCNP_DATA
export scale_data_dir=/opt/SCALE/data
export lapack_dir=/usr/lib/x86_64-linux-gnu

# Miscellaneous environment variables used by install scripts
export jobs=`grep -c processor /proc/cpuinfo`
export sudo_cmd=
export slurm_support=true
export geany_needs_intltool=false
export geant4_libdir=lib
export native_python=true
export native_setuptools=true
export native_pythonpacks=true
export native_exnihilo_packs=true

# Specify location of CMake
export PATH=${native_dir}/cmake-current/bin:${PATH}
export CMAKE=${native_dir}/cmake-current/bin/cmake

# Specify paths to compilers
if [ "${compiler}" == "native" ]; then
  export CC=/usr/bin/gcc
  export CXX=/usr/bin/g++
  export FC=/usr/bin/gfortran
  export compiler_lib_dirs=
elif [ "${compiler}" == "intel-18" ]; then
  export CC=${intel_dir}/bin/intel64/icc
  export CXX=${intel_dir}/bin/intel64/icpc
  export FC=${intel_dir}/bin/intel64/ifort
  export compiler_lib_dirs=${intel_dir}/compiler/lib/intel64
elif [ "${compiler}" == "custom" ]; then
  export CC=/usr/bin/gcc
  export CXX=/usr/bin/g++
  export FC=${intel_dir}/bin/intel64/ifort
  export compiler_lib_dirs=${intel_dir}/compiler/lib/intel64
fi

# Control which versions of MCNP/DAGMC are built
if [ "${compiler}" == "native" ]; then
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
