# adds an executable target.
# target name comes from current directory name by default
# may be overridden by setting TARGET before including this file

# controls whether target_common generates a unity build AIO
# exes should really not have enough files to need one.
# they should depend on libraries and have minimal code - just the entry point.
if(NOT DEFINED AUTO_AIO)
  set(AUTO_AIO FALSE)
endif()

# defines TARGET from name of current directory
# define HEADERS, SOURCES, AIO_SOURCE
include("${CMAKE_INCLUDE}/target_common.cmake")

add_executable(
  ${TARGET}
  ${HEADERS} 
  ${SOURCES} 
  ${AIO_SOURCE}
  )

set_target_properties(${TARGET}
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/"
    FOLDER "exes/"
)

forbid_exe_test_targets()
