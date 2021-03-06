CMAKE_MINIMUM_REQUIRED(VERSION 2.8 FATAL_ERROR)
CMAKE_POLICY(VERSION 2.8)

SET(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" "${CMAKE_MODULE_PATH}")

IF(NOT Torch_FOUND)
  FIND_PACKAGE(Torch)
ENDIF()
IF(NOT CUDA_FOUND)
  FIND_PACKAGE(CUDA 5.5 REQUIRED)
ENDIF()

FILE(GLOB luasrc *.lua)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "4.9.3")
    if(CUDA_VERSION VERSION_LESS "8.0")
      MESSAGE(STATUS "Found gcc >=5 and CUDA <= 7.5, adding workaround C++ flags")
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_FORCE_INLINES")
    endif(CUDA_VERSION VERSION_LESS "8.0")
  endif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "4.9.3")
endif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")

IF(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  IF(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "4.7" OR CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL "4.7" )
    SET(CXX_VERSION "c++11")
  ELSE()
    SET(CXX_VERSION "c++0x")
  ENDIF()
ELSE()
  SET(CMAKE_CXX_STANDARD 11)
ENDIF()

IF(APPLE)
  IF(${CUDA_VERSION} LESS 6.0)
    # work around for mac os x bug:
    # http://stackoverflow.com/questions/16286588/cuda-5-0-cmake-and-make-failing-on-osx-10-8-3
    if (NOT DEFINED CUDA_HOST_COMPILER AND CMAKE_C_COMPILER_ID STREQUAL "Clang" AND EXISTS /usr/bin/gcc)
      set(CUDA_HOST_COMPILER /usr/bin/gcc CACHE FILEPATH "Host side compiler used by NVCC")
      message(STATUS "Setting CMAKE_HOST_COMPILER to /usr/bin/gcc instead of ${CMAKE_C_COMPILER}.")
    endif()

    # bug on Apple
    LINK_DIRECTORIES("/usr/local/cuda/lib/")
  ELSEIF(${CUDA_VERSION} LESS 7.0)
    SET(CUDA_HOST_COMPILER clang)
    LIST(APPEND CUDA_NVCC_FLAGS "-Xcompiler -stdlib=libstdc++ -Xlinker -stdlib=libstdc++")
    IF("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libstdc++")
    ENDIF()
  ENDIF()
  # CUDA 7 supports clang and libc++ so no need to change anything
ENDIF(APPLE)

IF(CUDA_FOUND) 
  # Detect CUDA architecture and get best NVCC flags
  IF(NOT COMMAND CUDA_SELECT_NVCC_ARCH_FLAGS OR MSVC)
	 INCLUDE(${CMAKE_CURRENT_SOURCE_DIR}/cmake/FindCudaArch.cmake)
  ENDIF()
  LIST(APPEND CUDA_NVCC_FLAGS $ENV{TORCH_NVCC_FLAGS})
  CUDA_SELECT_NVCC_ARCH_FLAGS(NVCC_FLAGS_EXTRA $ENV{TORCH_CUDA_ARCH_LIST})
  LIST(APPEND CUDA_NVCC_FLAGS ${NVCC_FLAGS_EXTRA})
  
  INCLUDE_DIRECTORIES("${Torch_INSTALL_INCLUDE}/THC")
  LINK_DIRECTORIES("${Torch_INSTALL_LIB}")

  FILE(GLOB src-cuda *.cu)

  MESSAGE(STATUS "got cuda version " ${CUDA_VERSION})
  
  CUDA_ADD_LIBRARY(writeparam MODULE ${src-cuda})
  TARGET_LINK_LIBRARIES(writeparam luaT THC TH)
  IF(APPLE)
    SET_TARGET_PROPERTIES(writeparam PROPERTIES
      LINK_FLAGS "-undefined dynamic_lookup")
  ENDIF()
  
  MESSAGE(STATUS "CUDA_NVCC_FLAGS: ${CUDA_NVCC_FLAGS}")

  ### Torch packages supposes libraries prefix is "lib"
  SET_TARGET_PROPERTIES(writeparam PROPERTIES
    PREFIX "lib"
    IMPORT_PREFIX "lib")

  INSTALL(TARGETS writeparam
    RUNTIME DESTINATION "${Torch_INSTALL_LUA_CPATH_SUBDIR}"
    LIBRARY DESTINATION "${Torch_INSTALL_LUA_CPATH_SUBDIR}")
ENDIF(CUDA_FOUND)

INSTALL(
  FILES
  ${luasrc}
DESTINATION "${Torch_INSTALL_LUA_PATH_SUBDIR}/writeparam")
