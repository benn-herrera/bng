get_filename_component(LIB_TARGET "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

file(GLOB_RECURSE AIO_SOURCE RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/*AIO.cpp")
if(AIO_SOURCE)
  file(REMOVE "${AIO_SOURCE}")
endif()

file(GLOB_RECURSE HEADERS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
file(GLOB_RECURSE SOURCES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
file(GLOB_RECURSE TEST_SOURCES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.cpp" )
file(GLOB_RECURSE TEST_HEADERS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.h" )

list(REMOVE_ITEM SOURCES ${TEST_SOURCES})
list(REMOVE_ITEM HEADERS ${TEST_HEADERS})

if(SOURCES)
  set(AIO_SOURCE "${LIB_TARGET}AIO.cpp")
  file(WRITE "${AIO_SOURCE}" "// generated unity build file for ${LIB_TARGET}\n")
  foreach(SOURCE IN LISTS SOURCES)
    file(APPEND "${AIO_SOURCE}" "#include \"${SOURCE}\"\n")
  endforeach()
  set_source_files_properties(${SOURCES} PROPERTIES HEADER_FILE_ONLY true)
  # TODO: mechanism for allowing dynamic lib creation
  set(LIB_TYPE STATIC)
else()
  set(LIB_TYPE INTERFACE)
endif()

include_directories("${CMAKE_CURRENT_SOURCE_DIR}")

add_library(
  ${LIB_TARGET} ${LIB_TYPE}
   ${HEADERS} 
   ${SOURCES} 
   ${AIO_SOURCE}
  )

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

if(BNG_BUILD_TESTS AND TEST_SOURCES)
  set(RUN_LIB_TESTS_TARGET run_${LIB_TARGET}_tests)
  add_custom_target(${RUN_LIB_TESTS_TARGET} DEPENDS ${LIB_TARGET})
  set_target_properties(
    ${RUN_LIB_TESTS_TARGET} PROPERTIES 
    EXCLUDE_FROM_ALL TRUE
    EXCLUDE_FROM_DEFAULT_BUILD TRUE
    FOLDER "tests/"
    )
  set(ALL_RUN_TEST_TARGETS ${ALL_RUN_TEST_TARGETS} ${RUN_LIB_TESTS_TARGET} PARENT_SCOPE)  

  add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/dummy.txt"
    COMMAND echo
  )

  foreach(TEST_SOURCE IN LISTS TEST_SOURCES)
    get_filename_component(TEST_TARGET "${TEST_SOURCE}" NAME_WE)
    string(REPLACE "_test_" "" TEST_TARGET "${TEST_TARGET}")
    string(REPLACE "test_" "" TEST_TARGET "${TEST_TARGET}")
    string(REPLACE "test_" "" TEST_TARGET "${TEST_TARGET}")    
    set(TEST_TARGET "test_${LIB_TARGET}_${TEST_TARGET}")
    add_executable(${TEST_TARGET} ${TEST_HEADERS} ${TEST_SOURCE})
    set_target_properties(${TEST_TARGET}
        PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/tests/"
        FOLDER "tests/${LIB_TARGET}_tests"
    )
    add_dependencies(${RUN_LIB_TESTS_TARGET} ${TEST_TARGET})
    if((CMAKE_GENERATOR MATCHES "Ninja") OR (CMAKE_GENERATOR MATCHES "Make"))
      # single config
      add_custom_command(
        TARGET ${RUN_LIB_TESTS_TARGET}
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/test.dummy"
        COMMAND "${CMAKE_BINARY_DIR}/tests/${TEST_TARGET}")
    else()
      # multi config
      add_custom_command(
        TARGET ${RUN_LIB_TESTS_TARGET}
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/test.dummy"
        COMMAND "${CMAKE_BINARY_DIR}/tests/$<IF:$<CONFIG:Debug>,Debug,RelWithDebInfo>/${TEST_TARGET}")      
    endif()
    target_link_libraries(${TEST_TARGET} ${LIB_TARGET})
  endforeach()
endif()
