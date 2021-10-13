#!/bin/bash

set -e

export geant4_version=10.05.p01

build_prefix=${build_dir}/G4beamline-${g4beamline_version}
install_prefix=${install_dir}/G4beamline-${g4beamline_version}

openmpi_dir=/opt/software_native/openmpi-${openmpi_version}
geant4_dir=/opt/software_native/geant4-${geant4_version}
root_dir=/opt/software_native/root-${root_version}

rm -rfv ${build_prefix}
mkdir -pv ${build_prefix}/bld
cd ${build_prefix}
tarball=G4beamline-${g4beamline_version}-source.tgz
url="http://www.muonsinternal.com/muons3/G4beamlineDownload.php?download&ljacobson64@gmail.com&${tarball}"
if [ ! -f ${dist_dir}/geant4/${tarball} ]; then wget ${url} -O ${dist_dir}/geant4/${tarball}; fi
tar -xzvf ${dist_dir}/geant4/${tarball}
ln -sv G4beamline-${g4beamline_version}-source src
cd G4beamline-${g4beamline_version}-source

mv -v g4bl/CMakelists.txt     g4bl/CMakeLists.txt    
mv -v g4bldata/CMakelists.txt g4bldata/CMakeLists.txt
mv -v g4blgui/CMakelists.txt  g4blgui/CMakeLists.txt 
mv -v g4blmpi/CMakelists.txt  g4blmpi/CMakeLists.txt 
mv -v g4bltest/CMakelists.txt g4bltest/CMakeLists.txt

rm -fv MPI.cmake
echo "find_package(MPI REQUIRED)"                    >> MPI.cmake
echo "set(LIBS \${LIBS} \${MPI_CXX_LIBRARIES})"      >> MPI.cmake
echo "include_directories(\${MPI_CXX_INCLUDE_DIRS})" >> MPI.cmake

sed -i "s/set(CMAKE_INSTALL_PREFIX/#set(CMAKE_INSTALL_PREFIX/"                 CMakeLists.txt
sed -i "s/add_subdirectory(finalize)/#add_subdirectory(finalize)/"             CMakeLists.txt
sed -i "s/MPI_Type_struct/MPI_Type_create_struct/"                             g4bl/BLMPI.cc
sed -i "s/install(DIRECTORY \$ENV{ROOTSYS}/#install(DIRECTORY \$ENV{ROOTSYS}/" g4bl/CMakeLists.txt

patch -p0 <<'EOF'
--- CMakeLists.txt.orig
+++ CMakeLists.txt
@@ -99,18 +98,0 @@
-### RPATH
-###
-if(G4BL_ROOT)
-	if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
-		SET(CMAKE_INSTALL_RPATH 
-			"@executable_path/../root/lib;@executable_path/../lib")
-	elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
-		SET(CMAKE_INSTALL_RPATH "$ORIGIN/../root/lib;$ORIGIN/../lib")
-	endif()
-else()
-	if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
-		SET(CMAKE_INSTALL_RPATH "@executable_path/../lib")
-	elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
-		SET(CMAKE_INSTALL_RPATH "$ORIGIN/../lib")
-	endif()
-endif()
-
-###
EOF

cd ../bld

rpath_dirs=${openmpi_dir}/lib:${geant4_dir}/lib:${root_dir}/lib
if [ -n "${compiler_rpath_dirs}" ]; then
  rpath_dirs=${compiler_rpath_dirs}:${rpath_dirs}
fi

cmake_string=
cmake_string+=" -DG4BL_MPI=ON"
cmake_string+=" -DMPI_HOME=${openmpi_dir}"
cmake_string+=" -DGEANT4_DIR=${geant4_dir}"
cmake_string+=" -DROOT_DIR=${root_dir}"
cmake_string+=" -DGSL_DIR=/usr"
cmake_string+=" -DFFTW_DIR=/usr"
cmake_string+=" -DCMAKE_BUILD_TYPE=Release"
cmake_string+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
cmake_string+=" -DCMAKE_INSTALL_RPATH=${rpath_dirs}"

export ROOTSYS=${root_dir}

cmake ../src ${cmake_string}
make -j${num_cpus}
make -j${num_cpus} install

v1=$(echo ${geant4_version} | cut -f1,1 -d'.')
v2=$(echo ${geant4_version} | cut -f2,2 -d'.')
v3=$(echo ${geant4_version} | cut -f3,3 -d'.')
geant4_version_mod=${v1}.$((${v2})).$((${v3/p/}))
echo ${geant4_dir}/share/Geant4-${geant4_version_mod}/data > ${install_prefix}/.data
