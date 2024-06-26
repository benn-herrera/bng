TARGET=bng
include("${CMAKE_INCLUDE}/target_exe")

add_dependencies(${TARGET} core desktop)
