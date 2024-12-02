#!/usr/bin/env bash -x
THIS_SCRIPT=$(basename "${0}")
THIS_DIR=$(dirname "${0}")
# can't rely on realpath existing
THIS_DIR=$(cd "${THIS_DIR}"; pwd)

function is_true() {
  case "${1}" in
    # ${1^^} syntax for upper casing not available in old mac bash    
    t*|T*|y*|Y*|1) return 0;;
  esac
  return 1
}

function is_in() {
  local sub=${1}
  local str=${2}
  [[ "${str/${sub}/}" != "${str}" ]]
}

function usage_and_die() {
  cat << __EOF
usage: ${THIS_SCRIPT} [--help] | [--clean] [--ios] [--ios-sim] [cmake_arg1]...
    note: bootstrap.sh must have been run first.
    --ios: build for ios device
    --ios-sim: build for ios simulator    
    --clean: delete build directory first
    any cmake args must come after --clean, --build.
    src/cmake/options.cmake:
    $(awk '{ print (NR == 1 ? "" : "    ") $0 }' "${THIS_DIR}/src/cmake/options.cmake")
__EOF
  exit ${1:-0}
}


# respect envars
BUILD=${BUILD:-false}
GEN_CLEAN=${GEN_CLEAN:-false}
BUILD_IOS=${BUILD_IOS:-false}
BUILD_IOS_SIM=${BUILD_IOS_SIM:-true}

VCPKG_DIR=src/vcpkg
export VCPKG_ROOT=${THIS_DIR}/${VCPKG_DIR}
export PATH=${VCPKG_ROOT}:${PATH}

VCPKG=${VCPKG_ROOT}/vcpkg

case "$(uname)" in
  Darwin*) IS_MAC=true;;
  *) echo "unsupported platform $(uname). swift project can only be built on macOS." 1>&2; exit 1;;
esac

while [[ -n "${1}" ]]; do
  case "${1}" in
    -h*|--h*|-u*|--u*) usage_and_die;;
    --clean|-c) GEN_CLEAN=true; shift;;
    --build-ios|-ios) BUILD_IOS==true; shift;;
    --build-ios-sim*) BUILD_IOS_SIM==true; shift;;
    *) break;;
  esac
done

cd "${THIS_DIR}"

if ! [[ -f .venv/.activate && -x "${VCPKG}" ]]; then
  echo "run bootstrap.sh first." 2>&1
  exit 1
fi

function run_cmake_gen() {
  if ${GEN_CLEAN}; then
    (/bin/rm -rf "${BUILD_DIR}" 2>&1) > /dev/null
  fi

  if [[ -f "${BUILD_DIR}/CMakeCache.txt" ]]; then
    if ! (set -x && cd "${BUILD_DIR}" && cmake . "${@}"); then
      return 1
    fi
    return 0
  fi

  if [[ -n "${CMAKE_SYSTEM_NAME:-}" ]]; then
    set -- "-DCMAKE_SYSTEM_NAME=${CMAKE_SYSTEM_NAME}" "${@}"
  fi
  if [[ -n "${VCPKG_TARGET_TRIPLET:-}" ]]; then
    set -- "-DVCPKG_TARGET_TRIPLET=${VCPKG_TARGET_TRIPLET}" "${@}"
  fi
  if [[ -n "${BNG_OPTIMIZED_BUILD_TYPE:-}" ]]; then
    set -- "-DBNG_OPTIMIZED_BUILD_TYPE=${BNG_OPTIMIZED_BUILD_TYPE}" "${@}"
  fi
  #if [[ -n "${CMAKE_TOOLCHAIN_FILE}" ]]; then
  #  set -- "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}" "${@}"
  #fi
  set -- -G="Xcode" -DBNG_BUILD_TESTS=FALSE "${@}"
  if ! (cmake "${@}" -S src -B "${BUILD_DIR}"); then
    # if running on macos and the failure is no CMAKE_CXX_COMPILER could be found try
    # sudo xcode-select --reset
    # per https://stackoverflow.com/questions/41380900/cmake-error-no-cmake-c-compiler-could-be-found-using-xcode-and-glfw
    # this step was required after first time installation of xcode.
    return 1
  fi
}

function run_cmake_build() {
  if [[ -n "${SDK_TARGET}" ]]; then
    set -- "${@}" -- -sdk "${SDK_TARGET}"
  fi  
  if ! cmake --build "${BUILD_DIR}" --parallel "${!}"; then
    echo "BUILD FAILED!" 1>&2    
    return 1
  fi
}

if ${BUILD_IOS}; then
  ( BUILD_DIR=build_ios &&
    CMAKE_SYSTEM_NAME=iOS &&
    VCPKG_TARGET_TRIPLET=arm64-ios &&
    run_cmake_gen "${@}" &&
    run_cmake_build )
fi
if ${BUILD_IOS_SIM}; then
  ( BUILD_DIR=build_ios_simulator &&
    CMAKE_SYSTEM_NAME=iOS &&    
    VCPKG_TARGET_TRIPLET=arm64-ios-simulator &&
    SDK_TARGET=iphonesimulator &&
    BNG_OPTIMIZED_BUILD=BNG_DEBUG &&
    run_cmake_gen "${@}" &&
    run_cmake_build )
fi
