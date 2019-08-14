#!/bin/bash

set -e

build_prefix=${build_dir}/pyvisfile-${pyvisfile_version}
install_prefix=${install_dir}/pyvisfile-${pyvisfile_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}
cd ${build_prefix}
tarball=pyvisfile-${pyvisfile_version}.tar.gz
url=https://files.pythonhosted.org/packages/e5/6b/80f49e1eb35cab2c1236ec81d3782e54829bd52ac1862ef153be27ee5a77/${tarball}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
tar -xzvf ${dist_dir}/misc/${tarball}
cd pyvisfile-${pyvisfile_version}

silo_dir=${install_dir}/silo-${silo_version}
./configure.py --use-silo --silo-inc-dir=${silo_dir}/include --silo-lib-dir=${silo_dir}/lib

${sudo_cmd_install} mkdir -pv ${install_prefix}/lib/python2.7/site-packages
${sudo_cmd_install} mkdir -pv ${install_prefix}/lib/python3.6/site-packages

setup_string="--prefix=${install_prefix}"

PYTHONPATH=${install_prefix}/lib/python2.7/site-packages
${sudo_cmd_install} python setup.py install ${setup_string}
PYTHONPATH=${install_prefix}/lib/python3.6/site-packages
${sudo_cmd_install} python3 setup.py install ${setup_string}
