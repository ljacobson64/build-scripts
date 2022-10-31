#!/bin/bash

set -e

build_prefix=${build_dir}/ISC-${isc_version}
install_prefix=${install_dir}/ISC-${isc_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=ISC-${isc_version}.zip
unzip ${dist_dir}/mcnp/${tarball}
ln -sv ISC/Source src
sed -i "s/INSTALL(DIRECTORY data/INSTALL(DIRECTORY ..\/data/" ISC/Source/CMakeLists.txt
cd bld

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_C_COMPILER=${CC}"
cmake_string+=" -DCMAKE_CXX_COMPILER=${CXX}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install

isc_pythonpath=${install_prefix}/lib/python${python3_version_major}/site-packages
export PYTHONPATH=${isc_pythonpath}

cd ../ISC/Source/python
python setup.py build_ext
python setup.py install --prefix=${install_prefix}
d=$(cat ${isc_pythonpath}/easy-install.pth)
d=$(basename ${d})
ln -sv ${d}/isc ${isc_pythonpath}/isc

#python setup.py install --user
