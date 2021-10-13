#!/bin/bash

set -e

build_prefix=${build_dir}/swig-${swig_version}
install_prefix=${install_dir}/swig-${swig_version}

pcre_dir=${install_dir}/pcre-${pcre_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=swig-${swig_version}.tar.gz
url=https://sourceforge.net/projects/swig/files/swig/swig-${swig_version}/${tarball}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
tar -xzvf ${dist_dir}/misc/${tarball}
ln -sv swig-${swig_version} src
cd bld

config_string=
config_string+=" --without-alllang"
config_string+=" --with-python"
config_string+=" --with-pcre-prefix=${pcre_dir}"
config_string+=" --prefix=${install_prefix}"
config_string+=" CC=${CC} CXX=${CXX} FC=${FC}"
if [ -n "${compiler_rpath_dirs}" ]; then
  config_string+=" LDFLAGS=-Wl,-rpath,${compiler_rpath_dirs}:${pcre_dir}/lib"
else
  config_string+=" LDFLAGS=-Wl,-rpath,${pcre_dir}/lib"
fi

../src/configure ${config_string}
make -j${num_cpus}
make -j${num_cpus} install
