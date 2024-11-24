include_directories(
  "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include"
)

# centralize third party package finding here.
# remember to src/vcpkg/vcpkg port add <dependency>

# for header-only libraries just adding the find_package statement is enough
find_package(glm REQUIRED CONFIGURE)

# for link libraries will need to add something like
#   target_link_libraries(${TARGET} PRIVATE DEP_NAME::DEP_NAME)
# to the CMakeLists.txt 
