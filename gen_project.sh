#!/usr/bin/env bash
THIS_DIR=$(dirname "${0}")
# can't rely on realpath existing
THIS_DIR=$(cd "${THIS_DIR}"; pwd)

case "$(uname)" in
	MINGW*) IS_WIN=true;;
	Darwin*) IS_MAC=true;;
	Linux*) IS_LNX=true;;
  *) echo "unsupported platform $(uname)" 1>&2; exit 1;;
esac

cd "${THIS_DIR}"

if [[ ! -f .venv/.activate ]]; then
	echo "run bootstrap.sh first." 2>&1
	exit 1
fi

source .venv/.activate
mkdir -p build
cd build
cmake -DCMake_PYTHON=$(which python3) ..
