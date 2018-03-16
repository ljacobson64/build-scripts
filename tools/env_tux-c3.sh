#!/bin/bash

source versions.sh

export dist_dir=/groupspace/cnerg/users/jacobson/dist
export build_dir=/local.hd/cnergg/jacobson/build/${compiler}
export install_dir=/groupspace/cnerg/users/jacobson/opt/${compiler}
export native_dir=/groupspace/cnerg/users/jacobson/opt/native
export gcc_dir=${native_dir}/gcc-${gcc_version}
export intel_dir=/groupspace/cnerg/users/jacobson/intel/compilers_and_libraries_2018.1.163/linux
export python_dir=/groupspace/cnerg/users/jacobson/local
export mcnp_exe=/groupspace/cnerg/users/jacobson/MCNP/MCNP_CODE/bin/mcnp5
export DATAPATH=/groupspace/cnerg/users/jacobson/MCNP/MCNP_DATA

export jobs=`grep -c processor /proc/cpuinfo`
export sudo_cmd=
export slurm_support=false
export geany_needs_intltool=true

export LD_LIBRARY_PATH=
export PYTHONPATH=${python_dir}/lib/python2.7/site-packages

export install_mcnpx27=true
export install_fludag=true
export install_daggeant4=true

if [ "${compiler}" == "native" ]; then
  export CC=/usr/bin/gcc
  export CXX=/usr/bin/g++
  export FC=/usr/bin/gfortran

  export install_fludag=false
elif [ "${compiler}" == "gcc-7" ]; then
  export CC=${gcc_dir}/bin/gcc
  export CXX=${gcc_dir}/bin/g++
  export FC=${gcc_dir}/bin/gfortran
elif [ "${compiler}" == "intel-18" ]; then
  export CC=${intel_dir}/bin/intel64/icc
  export CXX=${intel_dir}/bin/intel64/icpc
  export FC=${intel_dir}/bin/intel64/ifort

  export install_fludag=false
elif [ "${compiler}" == "custom" ]; then
  export CC=${gcc_dir}/bin/gcc
  export CXX=${gcc_dir}/bin/g++
  export FC=${intel_dir}/bin/intel64/ifort

  export install_fludag=false
  export install_daggeant4=false
fi
