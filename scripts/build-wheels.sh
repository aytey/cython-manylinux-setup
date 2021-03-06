#!/bin/bash

#
# This script is a direct copy of:
#
#     https://github.com/pypa/python-manylinux-demo/blob/master/travis/build-wheels.sh
#
# where the package `python-manylinux-demo` has been changed to `pomona`
#

set -e -u -x

function repair_wheel {
    wheel="$1"
    if ! auditwheel show "$wheel"; then
        echo "Skipping non-platform wheel $wheel"
    else
        auditwheel repair "$wheel" --plat "$PLAT" -w /io/wheelhouse/
    fi
}


# Compile wheels
for PYBIN in /opt/python/*/bin; do
    "${PYBIN}/pip" install -r /io/dev-requirements.txt
    "${PYBIN}/pip" wheel /io/ --no-deps -w wheelhouse/
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    repair_wheel "$whl"
done

# Install packages and test
for PYBIN in /opt/python/*/bin/; do
    "${PYBIN}/pip" install pomona --no-index -f /io/wheelhouse
    (cd "$HOME"; "${PYBIN}/nosetests" pomona)
done

# EOF
