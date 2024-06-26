include("${CMAKE_INCLUDE}/target_lib.cmake")

if(BNG_IS_ANDROID)
  add_subdirectory(android)
elseif(IS_IOS)
  add_subdirectory(ios)
else()
  message(FATAL_ERROR "unsupported mobile platform ${BNG_PLATFORM}")
endif()
