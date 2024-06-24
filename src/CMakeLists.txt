cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)

set(CMAKE_CONFIGURATION_TYPES Debug RelWithDebInfo)

# some platform builds will have defined CMAKE_SYSTEM_NAME
# from the command line as they require setup to occur before project()
# 
if (CMAKE_SYSTEM_NAME)
  include(cmake/platform_init.cmake)
endif()

project(bng VERSION 0.1.0 LANGUAGES CXX C)

if (NOT BNG_PLATFORM)
  include(cmake/platform_init.cmake)
endif()

include(cmake/platform_config.cmake)
include(cmake/commands.cmake)

set(CMAKE_INCLUDE "${PROJECT_SOURCE_DIR}/cmake")

add_subdirectory(third_party)

include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR} 
  ${CMAKE_CURRENT_SOURCE_DIR}/api
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party
)

add_subdirectory(api)
add_subdirectory(core)
add_subdirectory(render)
add_subdirectory(engine)
add_subdirectory(platform)

if(ALL_TEST_TARGETS)
  add_custom_target(run_all_tests DEPENDS ${ALL_TEST_TARGETS})
  set_target_properties(
    run_all_tests PROPERTIES 
    EXCLUDE_FROM_ALL ${BNG_EXCLUDE_TESTS_FROM_DEFAULT_BUILD}
    EXCLUDE_FROM_DEFAULT_BUILD TRUE
    FOLDER "tests/" 
    )
endif()
