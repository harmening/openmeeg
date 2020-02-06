cmake_minimum_required (VERSION 3.12)
project (OpenMEEG VERSION 2.4.9999 LANGUAGES C CXX)

if(APPLE)
  # SET RPATH correct
  # use, i.e. don't skip the full RPATH for the build tree
  SET(CMAKE_SKIP_BUILD_RPATH  FALSE)
  # when building, don't use the install RPATH already
  # (but later on when installing)
  SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
  # the RPATH to be used when installing
  SET(CMAKE_INSTALL_RPATH "")
  # don't add the automatically determined parts of the RPATH
  # which point to directories outside the build tree to the install RPATH
  SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)

  set(CMAKE_C_COMPILER "/usr/local/Cellar/llvm/7.0.1/bin/clang")
  set(CMAKE_CXX_COMPILER "/usr/local/Cellar/llvm/7.0.1/bin/clang++")
  set(OPENMP_LIBRARIES "/usr/local/Cellar/llvm/7.0.1/lib")
  set(OPENMP_INCLUDES "/usr/local/Cellar/llvm/7.0.1/include")

  OPTION (USE_OpenMP "Use OpenMP to enamble <omp.h>" ON)

  # use python3.6 instead of 2.7
  #find_package( PythonInterp 3.6 REQUIRED )
  #find_package( PythonLibs 3.6 REQUIRED )
endif()


# Find OpenMP
if(APPLE AND USE_OpenMP)
    if(CMAKE_C_COMPILER_ID MATCHES "Clang")
        set(OpenMP_C "${CMAKE_C_COMPILER}")
        set(OpenMP_C_FLAGS "-fopenmp=libomp -Wno-unused-command-line-argument")
        set(OpenMP_C_LIB_NAMES "libomp" "libgomp" "libiomp5")
        set(OpenMP_libomp_LIBRARY ${OpenMP_C_LIB_NAMES})
        set(OpenMP_libgomp_LIBRARY ${OpenMP_C_LIB_NAMES})
        set(OpenMP_libiomp5_LIBRARY ${OpenMP_C_LIB_NAMES})
    endif()
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
      set(OpenMP_CXX "${CMAKE_CXX_COMPILER}")
      set(OpenMP_CXX_FLAGS "-fopenmp=libomp -Wno-unused-command-line-argument")
      set(OpenMP_CXX_LIB_NAMES "libomp" "libgomp" "libiomp5")
      set(OpenMP_libomp_LIBRARY ${OpenMP_CXX_LIB_NAMES})
      set(OpenMP_libgomp_LIBRARY ${OpenMP_CXX_LIB_NAMES})
      set(OpenMP_libiomp5_LIBRARY ${OpenMP_CXX_LIB_NAMES})
    endif()
endif()

if(USE_OpenMP)
  find_package(OpenMP REQUIRED)
endif(USE_OpenMP)

if(OPENMP_FOUND)
    include_directories("${OPENMP_INCLUDES}")
    link_directories("${OPENMP_LIBRARIES}")
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    # set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
endif(OPENMP_FOUND)


#set(CMAKE_CXX_STANDARD 11)  # use c++11
set(CMAKE_CXX_STANDARD 17)  # use c++17

set(OpenMEEG_HEADER_INSTALLDIR include) # XXX I don't know why this should be here

# Modify where to find the modules
list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/utils
    ${CMAKE_MODULE_PATH}
)

# OpenMEEG Configuration and needed things

include(GenerateExportHeader)
include(CompilerOptions)
include(options)
include(thirdParties)
include(install)  # install setup (do it before adding targets)
include(Uninstall)  # install setup (do it before adding targets)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/OpenMEEGConfigure.h.in
               ${CMAKE_CURRENT_BINARY_DIR}/OpenMEEGConfigure.h)

# OpenMEEG stuff

add_subdirectory(OpenMEEGMaths)
add_subdirectory(OpenMEEG)
add_subdirectory(apps)
add_subdirectory(documentation)
add_subdirectory(wrapping)
add_subdirectory(tests)

# OpenMEEG Export

# XXX: Hot fix to be able to ship win binaries when OpenMP is active
#
# see:https://braintrekking.wordpress.com/2013/04/27/dll-hell-how-to-include-microsoft-redistributable-runtime-libraries-in-your-cmakecpack-project/
# TODO:
#   - Build a test that fails if this is not active
#   - Find a way to find vcompXXX.dll in the system
#   - Place this in the proper place (probably the entire install.cmake/thirdparty.cmake needs refactor)
if (WIN32 AND OPENMP_FOUND AND VCOMP_WORKAROUND)
    set(VCOMP_PATH "C:/Program Files (x86)/Microsoft Visual Studio 14.0/VC/redist/x64/Microsoft.VC140.OpenMP/vcomp140.dll")
    INSTALL(FILES "${VCOMP_PATH}" DESTINATION bin COMPONENT Libraries)
endif()


include(cmake/Packaging.cmake)
