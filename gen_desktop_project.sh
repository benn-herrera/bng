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
BUILD=${BUILD:-false}
CMAKE_GENERATOR=${CMAKE_GENERATOR:-}
GEN_CLEAN=${GEN_CLEAN:-false}
TEST=${TEST:-false}
VCPKG_TARGET_TRIPLET=${VCPKG_TARGET_TRIPLET:-}

IS_LNX=false
IS_MAC=false
IS_WIN=false

VCPKG_DIR=src/vcpkg
export VCPKG_ROOT=${THIS_DIR}/${VCPKG_DIR}
export PATH=${VCPKG_ROOT}:${PATH}

VCPKG=${VCPKG_ROOT}/vcpkg

case "$(uname)" in
  Linux*) IS_LNX=true;;
  Darwin*) IS_MAC=true;;
  MINGW*) IS_WIN=true;;
  *) echo "unsupported platform $(uname)" 1>&2; exit 1;;
esac

if ${IS_LNX}; then
  CMAKE_GENERATOR=${CMAKE_GENERATOR:-Ninja}  
elif ${IS_MAC}; then
  CMAKE_GENERATOR=${CMAKE_GENERATOR:-Ninja}  
elif ${IS_WIN}; then
  VCPKG=${VCPKG}.exe
else
  echo "add setup for $(uname)." 1>&2; exit 1
fi

# stupid pet trick. support ninja build on windows.
if ${IS_WIN} && [[ "${CMAKE_GENERATOR}" == "Ninja" ]] && ! is_in --msvc "${*}"; then
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

if ${TEST}; then
  BUILD=true
fi

cd "${THIS_DIR}"

if ! [[ -f .venv/.activate && -x "${VCPKG}" ]]; then
  echo "run bootstrap.sh first." 2>&1
  exit 1
fi

BUILD_DIR=build_desktop

if ${GEN_CLEAN}; then
  (/bin/rm -rf "${BUILD_DIR}" 2>&1) > /dev/null
fi

function run_cmake_gen() {
  if [[ -n "${CMAKE_GENERATOR}" ]]; then
    set -- "-G=${CMAKE_GENERATOR}" "${@}"
  fi
  if ${TEST}; then
    set -- "${@}" -DBNG_BUILD_TESTS=TRUE
  fi
  if [[ -n "${VCPKG_TARGET_TRIPLET:-}" ]]; then
    set -- "-DVCPKG_TARGET_TRIPLET=${VCPKG_TARGET_TRIPLET}"
  fi
  set -- "${@}"  
  if ! (set -x && cmake "${@}" -S src -B "${BUILD_DIR}"); then
    # if running on macos and the failure is no CMAKE_CXX_COMPILER could be found try
    # sudo xcode-select --reset
    # per https://stackoverflow.com/questions/41380900/cmake-error-no-cmake-c-compiler-could-be-found-using-xcode-and-glfw
    # this step was required after first time installation of xcode.
    return 1
  fi
}

function run_cmake_build() {
  if ! ${BUILD}; then
    return 0
  fi
  if ! cmake --build "${BUILD_DIR}"; then
    echo "BUILD FAILED!" 1>&2    
    return 1
  fi
}

function run_cmake_test() {
  if ! ${TEST}; then
    return 0
  fi
  if ! cmake --build "${BUILD_DIR}" --target RUN_ALL_TESTS; then
    echo "TESTS FAILED!" 1>&2
    return 1
  fi
  echo "test suites all passed."
}

run_cmake_gen "${@}" && \
  run_cmake_build && \
  run_cmake_test
