#!/bin/bash

set -e

build_prefix=${build_dir}/DROSG2000-${drosg2000_version}
install_prefix=${install_dir}/DROSG2000-${drosg2000_version}

rm -rfv   ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd        ${build_prefix}
tarball=DROSG2000-v${drosg2000_version}.zip
url=https://www-nds.iaea.org/public/libraries/drosg2000/${tarball}
if [ ! -f ${dist_dir}/${tarball} ]; then wget ${url} -P ${dist_dir}/; fi
unzip ${dist_dir}/${tarball}
ln -sv pentiumpro src

cd pentiumpro

echo "cmake_minimum_required(VERSION 2.8)
project(DROSG2000 Fortran)

if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif ()

# Source files shared by all executables
set(SRC_FILES ANGCAL.f95
              ANGINP.f95
              CHKANG.f95
              eninpo.f95
              LEGINT.f95
              NEUYIE.f95)

# NEUYIE
add_executable(neuyie \${SRC_FILES} NYIOUT.f95)
target_include_directories(neuyie PUBLIC neuyie)
install(TARGETS neuyie DESTINATION bin)

# TIMREV
add_executable(timrev \${SRC_FILES} RECOUT.f95)
target_include_directories(timrev PUBLIC timrev)
install(TARGETS timrev DESTINATION bin)

# WHIYIE
add_executable(whiyie \${SRC_FILES} whiout.f95)
target_include_directories(whiyie PUBLIC whiyie)
install(TARGETS whiyie DESTINATION bin)

# Install data files
file(GLOB DATA_FILES *.tab *.TAB *.koe *.KOE)
foreach (DATA_FILE IN LISTS DATA_FILES)
  get_filename_component(DATA_FILE_OLD \${DATA_FILE} NAME)
  string(TOLOWER \${DATA_FILE_OLD} DATA_FILE_NEW)
  install(FILES \${DATA_FILE_OLD} RENAME \${DATA_FILE_NEW} DESTINATION bin)
endforeach ()" > CMakeLists.txt

mv -v neuyie/PARAM.NEU neuyie/param.neu
mv -v timrev/PARAM.NEU timrev/param.neu
mv -v whiyie/PARAM.NEU whiyie/param.neu
sed -i "s/MANG=181/MANG=7201/" `grep -rl MANG=181`
sed -i "      s/ 85 FORMAT(F11.2,F10.3,f10.5,F10.2,F10.3,10X,1P,E10.3/ 85 FORMAT(F9.3,1P,E13.5,0P,F10.5,F9.3,1P,E13.5,0P,10X,1P,E13.5/;
        s/185 FORMAT(F11.2,1P,E10.3,0P,f10.5,F10.2,1P,E10.3,10X,E10.3/185 FORMAT(F9.3,1P,E13.5,0P,F10.5,F9.3,1P,E13.5,0P,10X,1P,E13.5/;
        s/ 86 FORMAT(F11.2,F10.3,1P,E10.3,0P,F10.2,F10.3,10X,1P,E10.3/ 86 FORMAT(F9.3,1P,E13.5,0P,F10.5,F9.3,1P,E13.5,0P,10X,1P,E13.5/;
             s/186 FORMAT(F11.2,1P,2E10.3,0P,F10.2,1P,E10.3,10X,E10.3/186 FORMAT(F9.3,1P,E13.5,0P,F10.5,F9.3,1P,E13.5,0P,10X,1P,E13.5/" NYIOUT.f95
datadir=`echo ${install_prefix}/bin/ | sed 's/\//\\\\\//g'`
sed -i  "s/OPEN(UNIT=3,FILE=/OPEN(UNIT=3,FILE=\'${datadir}\'\/\//" NEUYIE.f95 ANGINP.f95
sed -i "s/OPEN (UNIT=3,FILE=/OPEN(UNIT=3,FILE=\'${datadir}\'\/\//" LEGINT.f95
sed -i  "s/open(unit=3,file=/OPEN(unit=3,file=\'${datadir}\'\/\//" whiout.f95
cd ../bld

cmake_string=
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_Fortran_COMPILER=${FC}"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"

${CMAKE} ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install
