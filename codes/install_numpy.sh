#!/bin/bash

set -e

build_prefix=${build_dir}/numpy-${numpy_version}
install_prefix=${install_dir}/numpy-${numpy_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}
cd ${build_prefix}
tarball=numpy-${numpy_version}.zip
url=https://files.pythonhosted.org/packages/d5/6e/f00492653d0fdf6497a181a1c1d46bbea5a2383e7faf4c8ca6d6f3d2581d/${tarball}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
unzip ${dist_dir}/misc/${tarball}
cd numpy-${numpy_version}

${sudo_cmd_install} mkdir -pv ${install_prefix}/lib/python3.8/site-packages
PYTHONPATH=${install_prefix}/lib/python3.8/site-packages

setup_string_1=
setup_string_1+=" -j${jobs}"
setup_string_2=
setup_string_2+=" --prefix=${install_prefix}"

${sudo_cmd_install} python setup.py build ${setup_string_1} install ${setup_string_2}
