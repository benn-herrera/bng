# build project generation options

set(BNG_BUILD_TESTS TRUE CACHE BOOL "add tests suites to project")
set(BNG_INCLUDE_BUILD_TESTS_IN_ALL TRUE CACHE BOOL "rebuild tests when project source changes")

set(BNG_OPTIMIZED_BUILD_TYPE BNG_DEBUG CACHE STRING "what it says on the tin")
set_property(CACHE BNG_OPTIMIZED_BUILD_TYPE PROPERTY STRINGS BNG_DEBUG BNG_RELEASE)
