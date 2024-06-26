# target_common.cmake
# defines TARGET from name of current directory
# define HEADERS, SOURCES, AIO_SOURCE

include("${CMAKE_INCLUDE}/test_macros.cmake")

if (NOT "${TARGET}")
  get_filename_component(TARGET "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
endif()

file(GLOB_RECURSE AIO_SOURCE RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/*AIO.cpp")
if(AIO_SOURCE)
  file(REMOVE "${AIO_SOURCE}")
endif()

file(GLOB_RECURSE HEADERS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
file(GLOB_RECURSE SOURCES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")

# defines TEST_SOURCES, TEST_HEADERS
collect_test_sources()

if(SOURCES)
  set(AIO_SOURCE "${TARGET}AIO.cpp")
  file(WRITE "${AIO_SOURCE}" "// generated unity build file for ${TARGET}\n")
  foreach(SOURCE IN LISTS SOURCES)
    file(APPEND "${AIO_SOURCE}" "#include \"${SOURCE}\"\n")
  endforeach()
  set_source_files_properties(${SOURCES} PROPERTIES HEADER_FILE_ONLY true)
endif()

include_directories("${CMAKE_CURRENT_SOURCE_DIR}")

if(USE_FOLDERS)
  foreach(HEADER IN LISTS HEADERS)
    get_filename_component(FOLDER "${HEADER}" DIRECTORY)
    if(FOLDER)
      source_group("Header Files/${FOLDER}" "${HEADER}")
    endif()
  endforeach()
  foreach(SOURCE IN LISTS SOURCES)
    get_filename_component(FOLDER "${SOURCE}" DIRECTORY)
    if(FOLDER)
      source_group("Source Files/${FOLDER}" "${SOURCE}")
    endif()
  endforeach()
endif()
