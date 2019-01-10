#!/bin/bash

source versions.sh

# Important directories
export dist_dir=/home/ljjacobson/dist
export build_dir=/scratch/local/ljjacobson/build/${compiler}
export install_dir=/home/group/dagmc/opt/${compiler}
export native_dir=/home/group/dagmc/opt/misc
export intel_dir=
export lapack_dir=/usr/lib64/atlas

export mcnp_exe=${native_dir}/MCNP/bin/mcnp5
export DATAPATH=${native_dir}/MCNP/MCNP_DATA
export scale_data_dir=${native_dir}/SCALE/data

# Miscellaneous environment variables used by install scripts
export jobs=`grep -c processor /proc/cpuinfo`
export sudo_cmd_install=
export sudo_cmd_native=
export slurm_support=true
export geany_needs_intltool=true
export geant4_libdir=lib64
export native_python=false
export native_setuptools=false
export native_pythonpacks=false
export native_exnihilo_packs=false

# Specify location of CMake
export PATH=${native_dir}/cmake/bin:${PATH}
export CMAKE=${native_dir}/cmake/bin/cmake

# Specify path to GCC
if   [ "${compiler}" == "gcc-5"  ]; then gcc_dir=${native_dir}/gcc-5.5.0
elif [ "${compiler}" == "gcc-6"  ]; then gcc_dir=${native_dir}/gcc-6.5.0
elif [ "${compiler}" == "gcc-7"  ]; then gcc_dir=${native_dir}/gcc-7.4.0
elif [ "${compiler}" == "gcc-8"  ]; then gcc_dir=${native_dir}/gcc-8.2.0
elif [ "${compiler}" == "custom" ]; then gcc_dir=${native_dir}/gcc-8.2.0
fi

# Specify path to intel compiler
if   [ "${compiler}" == "intel-13" ]; then intel_dir=/opt/intel
elif [ "${compiler}" == "intel-16" ]; then intel_dir=/opt/intel-2016
elif [ "${compiler}" == "custom"   ]; then intel_dir=/opt/intel-2016
fi

# Specify paths to compilers
if [ "${compiler}" == "native" ]; then
  export CC=/usr/bin/gcc
  export CXX=/usr/bin/g++
  export FC=/usr/bin/gfortran
  export compiler_lib_dirs=
elif [[ "${compiler}" == "gcc-"* ]]; then
  export CC=${gcc_dir}/bin/gcc
  export CXX=${gcc_dir}/bin/g++
  export FC=${gcc_dir}/bin/gfortran
  export compiler_lib_dirs=${gcc_dir}/lib64
elif [[ "${compiler}" == "intel-"* ]]; then
  export CC=${intel_dir}/bin/icc
  export CXX=${intel_dir}/bin/icpc
  export FC=${intel_dir}/bin/ifort
  export compiler_lib_dirs=${intel_dir}/lib/intel64
elif [ "${compiler}" == "custom" ]; then
  export CC=${gcc_dir}/bin/gcc
  export CXX=${gcc_dir}/bin/g++
  export FC=${intel_dir}/bin/ifort
  export compiler_lib_dirs=${gcc_dir}/lib64:${intel_dir}/lib/intel64
fi

# Control which versions of MCNP/DAGMC are built
if [ "${compiler}" == "native" ]; then
  export install_mcnpx27=true
  export install_fludag=false
  export install_daggeant4=false
elif [[ "${compiler}" == "gcc-"* ]]; then
  export install_mcnpx27=true
  export install_fludag=true
  export install_daggeant4=true
elif [[ "${compiler}" == "intel-"* ]]; then
  export install_mcnpx27=false
  export install_fludag=false
  export install_daggeant4=false
elif [ "${compiler}" == "custom" ]; then
  export install_mcnpx27=false
  export install_fludag=false
  export install_daggeant4=false
fi

# Set additional path environment variables
export PATH=${native_dir}/binutils/bin:${PATH}
export LD_LIBRARY_PATH=
export LIBRARY_PATH=${compiler_lib_dirs}
