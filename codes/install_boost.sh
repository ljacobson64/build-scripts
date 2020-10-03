#!/bin/bash

set -e

build_prefix=${build_dir}/boost-${boost_version}
install_prefix=${install_dir}/boost-${boost_version}

openmpi_dir=${install_dir}/openmpi-${openmpi_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}
cd ${build_prefix}
boost_version_with_underscores=${boost_version//./_}
tarball=boost_${boost_version_with_underscores}.tar.gz
url=https://dl.bintray.com/boostorg/release/${boost_version}/source/${tarball}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
tar -xzvf ${dist_dir}/misc/${tarball}
cd boost_${boost_version_with_underscores}

./bootstrap.sh --prefix=${install_prefix}

echo >> project-config.jam
echo "using mpi : ${openmpi_dir}/bin/mpicc ;" >> project-config.jam

if [ -n "${compiler_lib_dirs}" ]; then
  PATH=$(dirname ${CXX}):${PATH}
  LD_LIBRARY_PATH=${compiler_lib_dirs}
  rpath_dirs=${compiler_lib_dirs}:${install_prefix}/lib
else
  rpath_dirs=${install_prefix}/lib
fi

if [ "${native_python}" == "false" ]; then
  PATH=${install_dir}/python-${python2_version}/bin:${PATH}
fi

b2_string=
if [[ "${compiler}" == "intel-"* ]]; then
  b2_string+=" --toolset=intel"
fi
b2_string+=" link=shared"
b2_string+=" runtime-link=shared"
b2_string+=" linkflags=-Wl,-rpath,${rpath_dirs}"
b2_string+=" -j${num_cpus}"

${sudo_cmd_install} ./b2 ${b2_string} install
