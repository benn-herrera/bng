include("${CMAKE_INCLUDE}/target_lib.cmake")

add_dependencies(${TARGET} core api engine)

if(BNG_IS_WINDOWS)
  add_subdirectory(windows)
elseif(BNG_IS_LINUX)
  add_subdirectory(linux)
elseif(BNG_IS_MACOS)
  add_subdirectory(macos)
else()
  message(FATAL_ERROR "unsupported desktop platform ${BNG_PLATFORM}")
endif()