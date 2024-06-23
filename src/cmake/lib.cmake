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

set(AIO_SOURCE "${LIB_TARGET}AIO.cpp")
file(WRITE "${AIO_SOURCE}" "// generated unity build file for ${LIB_TARGET}\n")
foreach(SOURCE IN LISTS SOURCES)
	file(APPEND "${AIO_SOURCE}" "#include \"${SOURCE}\"\n")
endforeach()

include_directories("${CMAKE_CURRENT_SOURCE_DIR}")
set_source_files_properties(${SOURCES} PROPERTIES HEADER_FILE_ONLY true)

add_library(
	${LIB_TARGET} STATIC ${HEADERS} ${SOURCES} ${AIO_SOURCE}
	)

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

if(BNG_BUILD_TESTS)
	set(LIB_TARGET_TESTS run_${LIB_TARGET}_tests)
	add_custom_target(${LIB_TARGET_TESTS} DEPENDS ${LIB_TARGET})
	set_target_properties(
		${LIB_TARGET_TESTS} PROPERTIES 
		EXCLUDE_FROM_ALL true
		# EXCLUDE_FROM_DEFAULT_BUILD true	
		FOLDER "tests/"	
		)

	add_custom_command(
		OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/dummy.txt"
		COMMAND echo
	)

	foreach(TEST_SOURCE IN LISTS TEST_SOURCES)
		get_filename_component(TEST_TARGET "${TEST_SOURCE}" NAME_WE)
		set(TEST_TARGET "test_${LIB_TARGET}_${TEST_TARGET}")
		add_executable(${TEST_TARGET} EXCLUDE_FROM_ALL ${TEST_HEADERS} ${TEST_SOURCE})
		add_dependencies(${LIB_TARGET_TESTS} ${TEST_TARGET})
		add_custom_command(
			TARGET ${LIB_TARGET_TESTS}
			DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/dummy.txt"
			COMMAND "${CMAKE_BINARY_DIR}/tests/$<IF:$<CONFIG:Debug>,Debug,RelWithDebInfo>/${TEST_TARGET}")
		target_link_libraries(${TEST_TARGET} ${LIB_TARGET})
		set_target_properties(${TEST_TARGET}
		    PROPERTIES
		    EXCLUDE_FROM_ALL true
		    # EXCLUDE_FROM_DEFAULT_BUILD true
		    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/tests/"
		    FOLDER "tests/${LIB_TARGET}_tests"
		)	
	endforeach()
endif()