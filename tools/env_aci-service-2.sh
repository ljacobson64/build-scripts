#!/bin/bash

source versions.sh

export dist_dir=/home/ljjacobson/dist
export build_dir=/scratch/local/ljjacobson/build/${compiler}
export install_dir=/home/ljjacobson/opt/${compiler}
export python_dir=/home/ljjacobson/local
export mcnp_exe=/home/ljjacobson/MCNP/MCNP_CODE/bin/mcnp5
export DATAPATH=/home/ljjacobson/MCNP/MCNP_DATA

export jobs=`grep -c processor /proc/cpuinfo`
export SUDO=
export slurm_support=true
export geany_needs_intltool=true

export LD_LIBRARY_PATH=
export PYTHONPATH=${python_dir}/lib/python2.7/site-packages

if [ "${compiler}" == "gcc-7" ] || [ "${compiler}" == "custom" ]; then
  export gcc_dir=${install_dir}/native/gcc-${gcc_version}
  export PATH=${gcc_dir}/bin:${PATH}
  export LD_LIBRARY_PATH=${gcc_dir}/lib64:${LD_LIBRARY_PATH}
fi
if [ "${compiler}" == "intel-16" ] || [ "${compiler}" == "custom" ]; then
  export intel_dir=/opt/intel-2016/compilers_and_libraries_2016.2.181/linux
  export PATH=${intel_dir}/bin/intel64:${PATH}
  export LD_LIBRARY_PATH=${intel_dir}/compiler/lib/intel64:${LD_LIBRARY_PATH}
fi

export install_mcnpx27=true
export install_daggeant4=true
export install_fludag=true

if [ "${compiler}" == "native" ]; then
  export CC=/usr/lib64/ccache/gcc
  export CXX=/usr/lib64/ccache/g++
  export FC=/usr/bin/gfortran

  export install_daggeant4=false
  export install_fludag=false
elif [ "${compiler}" == "gcc-7" ]; then
  export CC=${gcc_dir}/bin/gcc
  export CXX=${gcc_dir}/bin/g++
  export FC=${gcc_dir}/bin/gfortran
elif [ "${compiler}" == "intel-16" ]; then
  export CC=${intel_dir}/bin/intel64/icc
  export CXX=${intel_dir}/bin/intel64/icpc
  export FC=${intel_dir}/bin/intel64/ifort

  export install_mcnpx27=false
  export install_daggeant4=false
  export install_fludag=false
elif [ "${compiler}" == "custom" ]; then
  export CC=${gcc_dir}/bin/gcc
  export CXX=${gcc_dir}/bin/g++
  export FC=${intel_dir}/bin/intel64/ifort

  export install_daggeant4=false
  export install_fludag=false
fi
