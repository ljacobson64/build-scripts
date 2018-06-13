#!/bin/bash

function setup_project() {
  cd ${build_prefix}
  mkdir -pv $1
  cd $1
  tarball=$2-${llvm_version}.src.tar.xz
  url=http://releases.llvm.org/${llvm_version}/${tarball}
  if [ ! -f ${dist_dir}/llvm/${tarball} ]; then wget ${url} -P ${dist_dir}/llvm/; fi
  tar -xJvf ${dist_dir}/llvm/${tarball}
  mv -v $2-${llvm_version}.src $3
}

set -e

build_prefix=${build_dir}/llvm-${llvm_version}
install_prefix=${install_dir}/llvm-${llvm_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld

setup_project .                      llvm              llvm
setup_project llvm/tools             cfe               clang
setup_project llvm/tools             lld               lld
setup_project llvm/tools             polly             polly
setup_project llvm/tools/clang/tools clang-tools-extra extra
setup_project llvm/projects          compiler-rt       compiler-rt
setup_project llvm/projects          libcxx            libcxx
setup_project llvm/projects          libcxxabi         libcxxabi
setup_project llvm/projects          libunwind         libunwind
setup_project llvm/projects          openmp            openmp
setup_project llvm/projects          test-suite        test-suite

cd ${build_prefix}
ln -sv llvm src
cd bld

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
if [ -n "${compiler_lib_dirs}" ]; then
  cmake_string+=" -DCMAKE_INSTALL_RPATH=${compiler_lib_dirs}"
fi

cmake ../src ${cmake_string}
make -j${jobs}
${sudo_cmd} make -j${jobs} install
