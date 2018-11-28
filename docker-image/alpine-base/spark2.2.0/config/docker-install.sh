#!/usr/bin/env sh
#
# all environment variables imported from Makefile context

# Exit script if you try to use an uninitialized variable.
set -o nounset

# Exit script if a statement returns a non-true return value.
set -o errexit

# Use the error status of the first failure, rather than that of the last item in a pipeline.
set -o pipefail

build_spark ()
{
    # use sub-shell to avoid side-effects of `cd`
    ( cd /assets; ./build-spark.sh )
}

docker_install ()
{
    apk --no-cache add bash
    apk --no-cache --update add \
        --virtual=build-dependencies \
        alpine-sdk \
        maven \
        python3 \
        openjdk8 \

    build_spark

    apk del build-dependencies
}

docker_install;
