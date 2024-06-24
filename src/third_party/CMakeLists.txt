set(THIRD_PARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
set(THIRD_PARTY_DIR "${THIRD_PARTY_DIR}" PARENT_SCOPE)
include(${CMAKE_INCLUDE}/third_party.cmake)

AddHeaderLib(glm https://github.com/g-truc/glm.git 1.0.1)
AddHeaderLib(stb https://github.com/nothings/stb.git master)
AddHeaderLib(mongoose https://github.com/cesanta/mongoose.git 7.14)
