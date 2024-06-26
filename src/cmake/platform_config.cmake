set(CMAKE_INCLUDE ${PROJECT_SOURCE_DIR}/cmake)

if(BNG_IS_WINDOWS)
  set(BNG_IS_DESKTOP TRUE)
  set(BNG_IS_MSVC TRUE)
  add_compile_definitions(BNG_IS_WINDOWS BNG_IS_DESKTOP)
elseif(BNG_IS_LINUX)
  set(BNG_IS_DESKTOP TRUE)  
  set(BNG_IS_CLANG TRUE)
  add_compile_definitions(BNG_IS_LINUX BNG_IS_DESKTOP)  
elseif(BNG_IS_MACOS)
  set(BNG_IS_DESKTOP TRUE)
  set(BNG_IS_APPLE TRUE)  
  set(BNG_IS_CLANG TRUE)
  add_compile_definitions(BNG_IS_MACOS BNG_IS_APPLE BNG_IS_DESKTOP)
elseif(BNG_IS_IOS)
  set(BNG_IS_MOBILE TRUE)
  set(BNG_IS_APPLE TRUE)
  set(BNG_IS_CLANG TRUE)
  add_compile_definitions(BNG_IS_IOS BNG_IS_APPLE BNG_IS_MOBILE)  
elseif(BNG_IS_ANDROID)
  set(BNG_IS_MOBILE TRUE) 
  set(BNG_IS_CLANG TRUE)
  add_compile_definitions(BNG_IS_ANDROID BNG_IS_MOBILE) 
else()
  message(FATAL_ERROR "add case for ${BNG_PLATFORM}")
endif()

if(BNG_IS_CLANG)
  add_compile_definitions(BNG_IS_CLANG) 
  add_compile_options(-Wall -Werror -fno-exceptions -fno-rtti -fvisibility=hidden)
elseif(BNG_IS_MSVC)
  add_compile_definitions(BNG_IS_MSVC)    
  add_compile_options(/wd4710 /Wall /WX /GR- /EHsc)
else()
  message(FATAL_ERROR "unsupported compiler.")
endif()

include("${CMAKE_INCLUDE}/options.cmake")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_C_STANDARD 17)

add_compile_definitions(
  $<IF:$<CONFIG:Debug>,BNG_DEBUG,>
  $<IF:$<CONFIG:RelWithDebInfo>,-D${BNG_OPTIMIZED_BUILD_TYPE},>
)

get_filename_component(REPO_ROOT_DIR "${PROJECT_SOURCE_DIR}" DIRECTORY)

set_property(GLOBAL PROPERTY USE_FOLDERS ${USE_FOLDERS})
# GLOB and GLOB_RECURSE are used for automatic target generation (see lib.cmake)
# add a FORCE_REGEN target for easy regen when files are added/removed/renamed.
add_custom_target(FORCE_REGEN)
set_target_properties(FORCE_REGEN PROPERTIES FOLDER "CMakePredefinedTargets")
add_custom_command(TARGET FORCE_REGEN 
  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}" 
  COMMAND "${CMAKE_COMMAND}" "${PROJECT_SOURCE_DIR}")
