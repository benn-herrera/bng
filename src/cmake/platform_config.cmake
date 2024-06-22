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
	add_compile_options(-Wall -Werror -fno-exceptions -fno-rtti -fvisibility=hidden -std=c++20)
elseif(BNG_IS_MSVC)
	add_compile_definitions(BNG_IS_MSVC)		
	add_compile_options(/wd4710 /Wall /WX /GR- /EHsc /std:c++20)
else()
	message(FATAL_ERROR "unsupported compiler.")
endif()


set(BNG_BUILD_TESTS BNG_DEBUG CACHE BOOL "what it says on the tin")

set(BNG_OPTIMIZED_BUILD_TYPE BNG_DEBUG CACHE STRING "what it says on the tin")
set_property(CACHE BNG_OPTIMIZED_BUILD_TYPE PROPERTY STRINGS BNG_DEBUG BNG_RELEASE)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

add_compile_definitions(
	$<IF:$<CONFIG:Debug>,BNG_DEBUG,>
	$<IF:$<CONFIG:RelWithDebInfo>,-D${BNG_OPTIMIZED_BUILD_TYPE},>
)
