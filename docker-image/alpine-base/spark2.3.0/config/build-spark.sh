#!/usr/bin/env bash
#
# all environment variables imported from Makefile context

# Exit script if you try to use an uninitialized variable.
set -o nounset

# Exit script if a statement returns a non-true return value.
set -o errexit

# Use the error status of the first failure, rather than that of the last item in a pipeline.
set -o pipefail

set -x

# Environment Variables
# ---------------------

declare -rx AZTK_DOCKER_IMAGE_VERSION=0.1.0 # set AZTK version compatibility
declare -rx AZTK_PYTHON_VERSION=3.5.2 # set version of python required for aztk

# modify these ARGs on build time to specify your desired versions of Spark/Hadoop
declare -rx SPARK_VERSION_KEY=2.3.0
declare -rx SPARK_FULL_VERSION="spark-${SPARK_VERSION_KEY}-bin-without-hadoop"
declare -rx HADOOP_VERSION=2.8.3
declare -rx LANG=C.UTF-8
declare -rx LC_ALL=C.UTF-8

declare -rx JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk/jre
declare -rx SPARK_HOME=/home/spark-current
declare -rx PATH="${SPARK_HOME}/bin:${PATH}"

function install_python ()
{
    # set up user python and aztk python
    python3 -m ensurepip
    rm -r /usr/lib/python*/ensurepip
    pip3 install --upgrade pip setuptools
    if [[ ! -e /usr/bin/pip ]]; then ln -s pip3 /usr/bin/pip ; fi
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi
}

function clone_spark_repo ()
{
    git clone --depth 1 --branch v${SPARK_VERSION_KEY} https://github.com/apache/spark.git
}

function compile_spark ()
{
    # build and install spark
    clone_spark_repo;
    export MAVEN_OPTS="-Xmx3g -XX:ReservedCodeCacheSize=1024m"
    (cd /assets/spark; ./dev/make-distribution.sh --name custom-spark --pip --tgz -Pnetlib-lgpl -Phive -Phive-thriftserver -Dhadoop.version=${HADOOP_VERSION} -DskipTests)
    tar -xvzf /assets/spark/spark-${SPARK_VERSION_KEY}-bin-custom-spark.tgz --directory=/home
    ln -s "/home/spark-${SPARK_VERSION_KEY}-bin-custom-spark" /home/spark-current
}

function copy_spark_jars ()
{
    # copy azure storage jars and dependencies to $SPARK_HOME/jars
    cp ./pom.xml /tmp
    cd /tmp
    mvn dependency:copy-dependencies -DoutputDirectory="${SPARK_HOME}/jars/"
}

function build_spark ()
{
    install_python;
    compile_spark;
    copy_spark_jars;
}

build_spark;
