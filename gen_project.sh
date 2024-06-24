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

function usage_and_die() {
  cat << __EOF
usage: ${THIS_SCRIPT} [--help] | [--clean] [--build] [cmake_arg1]...
    note: bootstrap.h must have been run first.
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

while [[ -n "${1}" ]]; do
  case "${1}" in
    -h*|--h*|-u*|--u*) usage_and_die;;
    --clean|-c) GEN_CLEAN=true; shift;;
    --build|-b) BUILD=true; shift;;
    --test|-t) TEST=true; shift;;
    *) break;;
  esac
done

case "$(uname)" in
  MINGW*) IS_WIN=true;;
  Darwin*) IS_MAC=true;;
  Linux*) IS_LNX=true; GENERATOR="-G=Ninja";;
  *) echo "unsupported platform $(uname)" 1>&2; exit 1;;
esac

cd "${THIS_DIR}"

if [[ ! -f .venv/.activate ]]; then
  echo "run bootstrap.sh first." 2>&1
  exit 1
fi

if ${GEN_CLEAN:-false}; then
  (/bin/rm -rf build 2>&1) > /dev/null
fi

mkdir -p build
cd build

if is_true ${TEST:-false}; then
  BUILD_TESTS="-DBNG_BUILD_TESTS=TRUE"
fi

if ! cmake ${GENERATOR} ${BUILD_TESTS} "${@}" "../src"; then
  exit 1
fi

if is_true ${TEST:-false}; then
  if cmake --build . --target RUN_ALL_TESTS; then
    echo "test suites all passed."
  else
    echo "TESTS FAILED!" 1>&2
    exit 1
  fi
elif is_true ${BUILD:-false}; then
  exec cmake --build .
fi
