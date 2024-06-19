cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)

# some platforms require setup to occur before project()
# the ones that don't, this won't hurt.
include(cmake/platform_init.cmake)

project(bng VERSION 0.1.0 LANGUAGES CXX C)

include(cmake/platform_config.cmake)

add_subdirectory(third_party)
add_subdirectory(core)
add_subdirectory(render)
add_subdirectory(engine)
add_subdirectory(platform)
