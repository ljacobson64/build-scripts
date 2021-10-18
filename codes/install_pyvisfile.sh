#!/bin/bash

set -e

build_prefix=${build_dir}/pyvisfile-${pyvisfile_version}
install_prefix=${install_dir}/pyvisfile-${pyvisfile_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}
cd ${build_prefix}
tarball=pyvisfile-${pyvisfile_version}.tar.gz
url=https://files.pythonhosted.org/packages/8f/3a/98fd38baf9bb1f37a7258a722841370cac7a110c1a73813a8056d7c28a42/${tarball}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
tar -xzvf ${dist_dir}/misc/${tarball}
cd pyvisfile-${pyvisfile_version}

silo_dir=${install_dir}/silo-${silo_version}
./configure.py --use-silo --silo-inc-dir=${silo_dir}/include --silo-lib-dir=${silo_dir}/lib

setup_string="--prefix=${install_prefix}"

mkdir -pv ${install_prefix}/lib/python${python2_version_major}/site-packages
PYTHONPATH=${install_prefix}/lib/python${python2_version_major}/site-packages
python2 setup.py install ${setup_string}

mkdir -pv ${install_prefix}/lib/python${python3_version_major}/site-packages
PYTHONPATH=${install_prefix}/lib/python${python3_version_major}/site-packages
python3 setup.py install ${setup_string}
