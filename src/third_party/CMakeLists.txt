set(THIRD_PARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
set(THIRD_PARTY_DIR "${THIRD_PARTY_DIR}" PARENT_SCOPE)
include(${CMAKE_INCLUDE}/third_party.cmake)

add_3p_header_lib(glm https://github.com/g-truc/glm.git 1.0.1 glm GLOB_RECURSE)
add_3p_header_lib(stb https://github.com/nothings/stb.git master . GLOB)
add_3p_header_lib(mongoose https://github.com/cesanta/mongoose.git 7.14 . GLOB)
