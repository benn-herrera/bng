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
	set(LIB_TARGET_TESTS run_${LIB_TARGET}_tests)
	add_custom_target(${LIB_TARGET_TESTS} DEPENDS ${LIB_TARGET})
	set_target_properties(
		${LIB_TARGET_TESTS} PROPERTIES 
		EXCLUDE_FROM_ALL ${BNG_EXCLUDE_TESTS_FROM_ALL_BUILD}
		EXCLUDE_FROM_DEFAULT_BUILD ${BNG_EXCLUDE_TESTS_FROM_ALL_BUILD}
		FOLDER "tests/"	
		)
	set(ALL_TEST_TARGETS ${ALL_TEST_TARGETS} ${LIB_TARGET_TESTS} PARENT_SCOPE)	

	add_custom_command(
		OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/dummy.txt"
		COMMAND echo
	)

	set(ALL_TEST_TARGETS ${ALL_TEST_TARGETS})
	foreach(TEST_SOURCE IN LISTS TEST_SOURCES)
		get_filename_component(TEST_TARGET "${TEST_SOURCE}" NAME_WE)
		set(TEST_TARGET "test_${LIB_TARGET}_${TEST_TARGET}")
		add_executable(${TEST_TARGET} ${TEST_HEADERS} ${TEST_SOURCE})
		set_target_properties(${TEST_TARGET}
		    PROPERTIES
		    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/tests/"
		    FOLDER "tests/${LIB_TARGET}_tests"
		)
		add_dependencies(${LIB_TARGET_TESTS} ${TEST_TARGET})
		if((CMAKE_GENERATOR MATCHES "Ninja") OR (CMAKE_GENERATOR MATCHES "Make"))
			# single config
			add_custom_command(
				TARGET ${LIB_TARGET_TESTS}
				DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/test.dummy"
				COMMAND "${CMAKE_BINARY_DIR}/tests/${TEST_TARGET}")
		else()
			# multi config
			add_custom_command(
				TARGET ${LIB_TARGET_TESTS}
				DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/test.dummy"
				COMMAND "${CMAKE_BINARY_DIR}/tests/$<IF:$<CONFIG:Debug>,Debug,RelWithDebInfo>/${TEST_TARGET}")			
		endif()
		target_link_libraries(${TEST_TARGET} ${LIB_TARGET})
	endforeach()
endif()
