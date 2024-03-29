#!/bin/bash

set -e
export compiler=$1
shift
packages="$@"
source tools/env_$(hostname -s).sh
export script_dir=${PWD}

if [ ! -e "${CC}"    ]; then echo "Error: C compiler not found at ${CC}"       && exit 1; fi
if [ ! -e "${CXX}"   ]; then echo "Error: C++ compiler not found at ${CXX}"    && exit 1; fi
if [ ! -e "${FC}"    ]; then echo "Error: Fortran compiler not found at ${FC}" && exit 1; fi
if [ ! -e "${CMAKE}" ]; then echo "Error: CMake not found at ${CMAKE}"         && exit 1; fi

echo "dist_dir:    ${dist_dir}"
echo "build_dir:   ${build_dir}"
echo "install_dir: ${install_dir}"
echo "CC:          ${CC}"
echo "CXX:         ${CXX}"
echo "FC:          ${FC}"
echo "CMAKE:       ${CMAKE}"
echo "num_cpus:    ${num_cpus}"
echo
${CC}    --version
${CXX}   --version
${FC}    --version
${CMAKE} --version
echo
sleep 1

intel_allowed="hdf5 moab openmpi mcnp dagmc"

for package in ${packages}; do
  if [[ "${package}" == *"-"* ]]; then
    name=$(cut -d '-' -f1  <<< "${package}")
    version=$(cut -d '-' -f2- <<< "${package}")
    eval ${name}_version=${version}
  else
    name=${package}
    temp=${name}_version
    eval version=${!temp}
  fi
  export ${name}_version
  if [ "${compiler}" == "intel" ] && ! echo "${intel_allowed}" | grep -w -q "${name}"; then
    echo "Error: cannot build package ${name} with intel compiler"
    exit 1
  fi
  echo "Building ${name} version ${version}"
  codes/install_${name}.sh
done
