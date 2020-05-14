project(DROSG2000 Fortran)
cmake_minimum_required(VERSION 2.8)

set(CMAKE_BUILD_TYPE Release)
set(CMAKE_Fortran_FLAGS_RELEASE "-O1")

# Source files shared by all executables
set(SRC_FILES ANGCAL.f95
              ANGINP.f95
              CHKANG.f95
              eninpo.f95
              LEGINT.f95
              NEUYIE.f95)

# NEUYIE
add_executable(neuyie ${SRC_FILES} NYIOUT.f95)
target_include_directories(neuyie PUBLIC neuyie)
install(TARGETS neuyie DESTINATION bin)

# TIMREV
add_executable(timrev ${SRC_FILES} RECOUT.f95)
target_include_directories(timrev PUBLIC timrev)
install(TARGETS timrev DESTINATION bin)

# WHIYIE
add_executable(whiyie ${SRC_FILES} whiout.f95)
target_include_directories(whiyie PUBLIC whiyie)
install(TARGETS whiyie DESTINATION bin)

# Install data files
file(GLOB DATA_FILES *.tab *.TAB *.koe *.KOE)
foreach (DATA_FILE IN LISTS DATA_FILES)
  get_filename_component(DATA_FILE_OLD ${DATA_FILE} NAME)
  string(TOLOWER ${DATA_FILE_OLD} DATA_FILE_NEW)
  install(FILES ${DATA_FILE_OLD} RENAME ${DATA_FILE_NEW} DESTINATION bin)
endforeach ()
