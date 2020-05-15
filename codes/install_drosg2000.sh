#!/bin/bash

set -e

build_prefix=${build_dir}/DROSG2000-${drosg2000_version}
install_prefix=${native_dir}/DROSG2000-${drosg2000_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=DROSG2000-v${drosg2000_version}.zip
url=https://www-nds.iaea.org/public/libraries/drosg2000/${tarball}
if [ ! -f ${dist_dir}/misc/${tarball} ]; then wget ${url} -P ${dist_dir}/misc/; fi
unzip ${dist_dir}/misc/${tarball}
ln -sv pentiumpro src

cd pentiumpro
ln -sv ${script_dir}/codes/drosg2000/CMakeLists.txt .
mv -v neuyie/PARAM.NEU neuyie/param.neu
mv -v timrev/PARAM.NEU timrev/param.neu
mv -v whiyie/PARAM.NEU whiyie/param.neu
sed -i "s/MANG=181/MANG=7201/" `grep -rl MANG=181`
sed -i "s/85 FORMAT(F11.2,F10.3,f10.5,F10.2,F10.3/85 FORMAT(F9.3,1P,E13.5,0P,F10.5,F9.3,1P,E13.5,0P/;
        s/86 FORMAT(F11.2,F10.3,1P,E10.3,0P,F10.2,F10.3/86 FORMAT(F9.3,1P,E13.5,0P,F10.5,F9.3,1P,E13.5,0P/" NYIOUT.f95
datadir=`echo ${install_prefix}/bin/ | sed 's/\//\\\\\//g'`
sed -i "s/OPEN(UNIT=3,FILE=/OPEN(UNIT=3,FILE=\'${datadir}\'\/\//" NEUYIE.f95 ANGINP.f95
sed -i "s/OPEN (UNIT=3,FILE=/OPEN(UNIT=3,FILE=\'${datadir}\'\/\//" LEGINT.f95
sed -i "s/open(unit=3,file=/OPEN(unit=3,file=\'${datadir}\'\/\//" whiout.f95
cd ../bld

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

cmake ../src ${cmake_string}
make -j${jobs}
${sudo_cmd_install} make -j${jobs} install
