#!/bin/bash

source versions.sh

export dist_dir=/NV/jacobson/dist
export build_dir=/home/jacobson/build/${compiler}
export install_dir=/compute_dir/opt/${compiler}
export native_dir=/compute_dir/opt/native
export gcc_dir=
export intel_dir=/compute_dir/intel/compilers_and_libraries_2018.1.163/linux
export python_dir=/compute_dir/local
export mcnp_exe=/compute_dir/MCNP/MCNP_CODE/bin/mcnp5
export DATAPATH=/compute_dir/MCNP/MCNP_DATA

export jobs=`grep -c processor /proc/cpuinfo`
export sudo_cmd=sudo
export slurm_support=true
export geany_needs_intltool=false

export LD_LIBRARY_PATH=
export PYTHONPATH=${python_dir}/lib/python2.7/site-packages

export install_mcnpx27=true
export install_fludag=true
export install_daggeant4=true

if [ "${compiler}" == "native" ]; then
  export CC=/usr/bin/gcc
  export CXX=/usr/bin/g++
  export FC=/usr/bin/gfortran
elif [ "${compiler}" == "intel-18" ]; then
  export CC=${intel_dir}/bin/intel64/icc
  export CXX=${intel_dir}/bin/intel64/icpc
  export FC=${intel_dir}/bin/intel64/ifort
  export compiler_lib_dirs=${intel_dir}/compiler/lib/intel64

  export install_fludag=false
elif [ "${compiler}" == "custom" ]; then
  export CC=/usr/bin/gcc
  export CXX=/usr/bin/g++
  export FC=${intel_dir}/bin/intel64/ifort
  export compiler_lib_dirs=${intel_dir}/compiler/lib/intel64

  export install_fludag=false
  export install_daggeant4=false
fi
