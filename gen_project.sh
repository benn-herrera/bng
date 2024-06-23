#!/usr/bin/env bash
THIS_SCRIPT=$(basename "${0}")
THIS_DIR=$(dirname "${0}")
# can't rely on realpath existing
THIS_DIR=$(cd "${THIS_DIR}"; pwd)

function is_true() {
	case "${1}" in
		# ${1^^} syntax for upper casing not available in old mac bash		
		t*|T*|y*|Y*|1) return 0;;
		"") return "${2:-1}";;
	esac
	return 1
}

function usage_and_die() {
	cat << __EOF
usage: ${THIS_SCRIPT} [--help] | [--clean] [--build] [cmake_arg1]...
    note: bootstrap.h must have been run first.
    --build: build and run tests
    --clean: delete build directory first
    any cmake args must come after --clean, --build, -G
    some potential cmake args. see src/cmake/options.cmake:
    	-DBNG_BUILD_TESTS=[TRUE|FALSE] 
    	-DBNG_OPTIMIZED_BUILD_TYPE=[BNG_DEBUG|BNG_RELEASE]
    	-DBNG_INCLUDE_BUILD_TESTS_IN_ALL=[TRUE|FALSE]
__EOF
	exit ${1:-0}
}

# respect envars
GEN_CLEAN=${GEN_CLEAN:-""}
BUILD=${BUILD:-""}

while [[ -n "${1}" ]]; do
	case "${1}" in
		-h*|--h*|-u*|--u*) usage_and_die;;
		--clean|-c) GEN_CLEAN=true; shift;;
		--build|-b) BUILD=true; shift;;
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

if ! cmake ${GENERATOR} "${@}" "../src"; then
	exit 1
fi

# TODO: generate a run all tests target
if is_true ${BUILD:-false}; then
	cmake --build . --target clean && \
	cmake --build . && \
	(
		export PATH=".:${PATH}"
		cd tests
		if [[ -d Debug ]]; then
			cd Debug
		fi
		EC=0
		for TEST in $(/bin/ls test_* | grep -v 'pdb'); do
			if ! "${TEST}"; then
				EC=1
			fi
		done
		if [[ ${EC} == 0 ]]; then
			echo "all suites passed."
		else
			echo "one or more suites FAILED" 1>&2
		fi
		exit ${EC}
	)
fi
