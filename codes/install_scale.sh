#!/bin/bash

set -e

build_prefix=${build_dir}/SCALE-${scale_version}
install_prefix=${install_dir}/SCALE-${scale_version}

export INSTALL_PATH=${install_prefix}
export MPI=${install_dir}/openmpi-${openmpi_version}
export DATA=${scale_data_dir}
export LAPACK=${lapack_dir}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
scale_tar_dir=SCALE-${scale_version::-2}-serial-${scale_version}-Source
tarball=${scale_tar_dir}.zip
unzip ${dist_dir}/scale/${tarball}
ln -sv ${scale_tar_dir} src

cd ${scale_tar_dir}/Trilinos/packages/anasazi/src
sed -i "s/ASSERT_DEFINED(Anasazi/#ASSERT_DEFINED(Anasazi/" CMakeLists.txt
cd ${build_prefix}/bld

cp -pv ../src/script/configure_scale_mpi.sh .
sed -i "s/export INSTALL_PATH=/#export INSTALL_PATH=/;
        s/DATA=/#DATA=/;
        s/MPI=/#MPI=/;
        s/LAPACK=/#LAPACK=/" configure_scale_mpi.sh
chmod +x configure_scale_mpi.sh

./configure_scale_mpi.sh ../src
make -j${num_cpus}
make -j${num_cpus} install
