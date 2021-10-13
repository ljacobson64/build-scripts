#!/bin/bash

source versions.sh
export python3_version=3.6.10

# Important directories
export dist_dir=/home/ljjacobson/dist
export build_dir=/scratch/local/ljjacobson/build/${compiler}
export install_dir=/software/groups/dagmc/opt/${compiler}
export native_dir=/software/groups/dagmc/opt/misc
export local_dir=/home/ljjacobson/.local

# Miscellaneous directories
export lapack_dir=/usr/lib64                    # SCALE
export mcnp_exe=${native_dir}/MCNP/bin/mcnp5    # lava, ADVANTG
export DATAPATH=${native_dir}/MCNP/MCNP_DATA    # FRENSIE
export scale_data_dir=${native_dir}/SCALE/data  # SCALE

# Miscellaneous environment variables
export num_cpus=3
export custom_boost=true
export custom_eigen=true
export custom_exnihilo_packs=true
export custom_lapack=true
export custom_python=true
export system_has_java=false
export system_has_latex=false
export system_has_x11=false

# Specify location of CMake
export CMAKE=${native_dir}/cmake/bin/cmake

# Specify paths to compilers
if [ "${compiler}" == "native" ]; then
  export CC=/usr/bin/gcc
  export CXX=/usr/bin/g++
  export FC=/usr/bin/gfortran
  export compiler_rpath_dirs=
elif [ "${compiler}" == "gcc-9" ]; then
  export gcc_dir=/software/chtc/easybuild/v2/software/GCCcore/9.3.0
  module load gcc/9.3.0
  export CC=`which gcc`
  export CXX=`which g++`
  export FC=`which gfortran`
  export compiler_rpath_dirs=${gcc_dir}/lib64
elif [ "${compiler}" == "intel" ]; then
  export intel_dir=/opt/intel/oneapi
  source ${intel_dir}/setvars.sh
  export CC=${intel_dir}/compiler/latest/linux/bin/intel64/icc
  export CXX=${intel_dir}/compiler/latest/linux/bin/intel64/icpc
  export FC=${intel_dir}/compiler/latest/linux/bin/intel64/ifort
  export compiler_rpath_dirs=${intel_dir}/compiler/latest/linux/compiler/lib/intel64
fi

# Control which versions of MCNP/DAGMC are built
if [ "${compiler}" == "native" ]; then
  export install_fludag=true
  export install_daggeant4=true
elif [ "${compiler}" == "gcc-9" ]; then
  export install_fludag=true
  export install_daggeant4=true
elif [ "${compiler}" == "intel" ]; then
  export install_fludag=false
  export install_daggeant4=false
fi

# Major python versions
export python2_version_major=$(echo ${python2_version} | cut -f1,2 -d'.')
export python3_version_major=$(echo ${python3_version} | cut -f1,2 -d'.')

# Functions to load python variables
load_python2() {
  export python2_dir=${install_dir}/python-${python2_version}
  export PATH=${python2_dir}/bin:${PATH}
  export PYTHONPATH=${python2_dir}/lib/python${python2_version_major}/site-packages
}
load_python3() {
  export python3_dir=${install_dir}/python-${python3_version}
  export PATH=${python3_dir}/bin:${PATH}
  export PYTHONPATH=${python3_dir}/lib/python${python3_version_major}/site-packages
}
