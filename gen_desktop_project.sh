#!/usr/bin/env bash
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
usage: ${THIS_SCRIPT} [--help] | [--clean] [--build] [--test] [cmake_arg1]...
    note: bootstrap.sh must have been run first.
    --build: build after generating project
    --test: build and run tests after generating project. exit status reflects test result.
    --clean: delete build directory first
    any cmake args must come after --clean, --build.
    src/cmake/options.cmake:
    $(awk '{ print (NR == 1 ? "" : "    ") $0 }' "${THIS_DIR}/src/cmake/options.cmake")
__EOF
  exit ${1:-0}
}


# respect envars
GEN_CLEAN=${GEN_CLEAN:-""}
BUILD=${BUILD:-""}
TEST=${TEST:-""}
GENERATOR=${GENERATOR:-""}

case "$(uname)" in
  MINGW*) IS_WIN=true;;
  Darwin*) IS_MAC=true; GENERATOR=${GENERATOR:-Ninja};;
  Linux*) IS_LNX=true; GENERATOR=${GENERATOR:-Ninja};;
  *) echo "unsupported platform $(uname)" 1>&2; exit 1;;
esac

# stupid pet trick. support ninja build on windows.
if is_true ${IS_WIN:-false} && [[ "${GENERATOR}" == "Ninja" ]] && ! is_in --msvc "${*}"; then
  THIS_SCRIPT="${THIS_DIR}/${THIS_SCRIPT}"
  # this hard path is brittle. if this becomes more than a stupid pet trick add resiliency logic.
  script=$(cat << __EOF
    call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
    "C:\Program Files\git\bin\bash.exe" "${THIS_SCRIPT}" --msvc ${@}
__EOF
  )
  exec cmd <<< "${script}"
fi

while [[ -n "${1}" ]]; do
  case "${1}" in
    -h*|--h*|-u*|--u*) usage_and_die;;
    --clean|-c) GEN_CLEAN=true; shift;;
    --build|-b) BUILD=true; shift;;
    --test|-t) TEST=true; shift;;
    --msvc) shift;;
    *) break;;
  esac
done

if is_true ${TEST:-false}; then
  BUILD=true
fi

cd "${THIS_DIR}"

if [[ ! -f .venv/.activate ]]; then
  echo "run bootstrap.sh first." 2>&1
  exit 1
fi

VCPKG_ROOT=${VCPKG_ROOT:-""}
if [[ ! -d "${VCPKG_ROOT}" ]]; then
  export VCPKG_ROOT=$(dirname "$(which vcpkg)")
fi

BUILD_DIR=build_desktop

if is_true ${GEN_CLEAN:-false}; then
  (/bin/rm -rf "${BUILD_DIR}" 2>&1) > /dev/null
fi

mkdir -p "${BUILD_DIR}"

function run_cmake_gen() {
  if [[ -n "${GENERATOR}" ]]; then
    set -- "-G=${GENERATOR}" "${@}"
  fi
  if is_true ${TEST:-false}; then
    set -- "${@}" -DBNG_BUILD_TESTS=TRUE
  fi
  set -- "-DCMAKE_TOOLCHAIN_FILE=${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" "${@}"  
  if ! (set -x && cmake "${@}" -S src -B "${BUILD_DIR}"); then
    # if running on macos and the failure is no CMAKE_CXX_COMPILER could be found try
    # sudo xcode-select --reset
    # per https://stackoverflow.com/questions/41380900/cmake-error-no-cmake-c-compiler-could-be-found-using-xcode-and-glfw
    # this step was required after first time installation of xcode.
    return 1
  fi
}

function run_cmake_build() {
  if ! is_true ${BUILD:-false}; then
    return 0
  fi
  if ! (cd "${BUILD_DIR}"; cmake --build .); then
    echo "BUILD FAILED!" 1>&2    
    return 1
  fi
}

function run_cmake_test() {
  if ! is_true ${TEST:-false}; then
    return 0
  fi
  if ! (cd "${BUILD_DIR}"; cmake --build . --target RUN_ALL_TESTS); then
    echo "TESTS FAILED!" 1>&2
    return 1
  fi
  echo "test suites all passed."
}

run_cmake_gen "${@}" && \
  run_cmake_build && \
  run_cmake_test

