if(PROJECT_BINARY_DIR)
  message(FATAL_ERROR "include in top level CMakeLists.txt before call to project()")
endif()

# vcpkg init

# if a platform toolchain file is specified
if(CMAKE_TOOLCHAIN_FILE AND NOT CMAKE_TOOLCHAIN_FILE MATCHES "vcpkg.cmake$")
  # shift it to the vcpkg chain load variable
  set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_TOOLCHAIN_FILE}")
  unset(CMAKE_TOOLCHAIN_FILE)
endif()

if(NOT VCPKG_ROOT)
  set(VCPKG_ROOT "$ENV{VCPKG_ROOT}" CACHE PATH "")
endif()

if(NOT IS_DIRECTORY "${VCPKG_ROOT}")
  message(FATAL_ERROR "VCPKG_ROOT=${VCPKG_ROOT} - must be set to a valid vcpkg installation")
endif()

# give vcpkg its chance to shim
set(CMAKE_TOOLCHAIN_FILE "${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
