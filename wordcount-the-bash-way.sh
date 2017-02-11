#!/bin/bash

# By: Ross MacDonald
# This script will prepare a system for the execution of a test hadoop and spark job
# THe file will check for all necessary dependencies and resolve them if required.

# Adjust versions here as required
HADOOP_VERSION=2.7.3
SPARK_VERSION=2.1.0
SPARK_FOR_HADOOP_VERSION=2.7
JAVA_VERSION=8

# Build the file name for the requested version of Hadoop
HADOOP_FILE_NAME="./hadoop-${HADOOP_VERSION}.tar.gz"
HADOOP_INSTALL_DIR="./hadoop-${HADOOP_VERSION}"

# Build the file name for the requested version of Spark
SPARK_FILE_NAME="./spark-${SPARK_VERSION}-bin-hadoop${SPARK_FOR_HADOOP_VERSION}.tgz"
SPARK_INSTALL_DIR="./spark-${SPARK_VERSION}-bin-hadoop${SPARK_FOR_HADOOP_VERSION}"

# Only download and install if hadoop isn't already installed!
if [ ! -d ${HADOOP_INSTALL_DIR} ]
    then
    
    echo "Hadoop install not detected, checking if tarball exists"
    echo "Looking for ${HADOOP_FILE_NAME}"
    # Check to see if the download exists, if not, get it.
    if [ ! -e ${HADOOP_FILE_NAME} ]
    then
        echo "Hadoop tarball not found, downloading it"
        wget -q http://muug.ca/mirror/apache-dist/hadoop/common/hadoop-${HADOOP_VERSION}/${HADOOP_FILE_NAME} .
    fi 
    
    # Let's make sure the file downloaded properly!
    if [ -f ${HADOOP_FILE_NAME} ]
    then
        echo "Tarball found, extracting"
        # #xtract it here
        tar xf ${HADOOP_FILE_NAME}
        if [ $? -eq 0 ]
        then
            echo "Extraction completed successfully"
        else
            echo "Extraction failed, exiting"
            exit 1
        fi
    else
        echo "Hadoop download failed, exiting"
        exit 1
    fi
else
    echo "Hadoop already installed, skipping download and install phase"
fi

# Only download and install if spark isn't already installed!
if [ ! -d ${SPARK_INSTALL_DIR} ]
    then
    
    echo "Spark install not detected, checking if tarball exists"
    echo "Looking for ${SPARK_FILE_NAME}"
    # Check to see if the download exists, if not, get it.
    if [ ! -e ${SPARK_FILE_NAME} ]
    then
        echo "Spark tarball not found, downloading it"
        wget -q http://d3kbcqa49mib13.cloudfront.net/${SPARK_FILE_NAME} .
    fi 
    
    # Let's make sure the file downloaded properly!
    if [ -f ${SPARK_FILE_NAME} ]
    then
        echo "Tarball found, extracting"
        # #xtract it here
        tar xf ${SPARK_FILE_NAME}
        if [ $? -eq 0 ]
        then
            echo "Extraction completed successfully"
        else
            echo "Extraction failed, exiting"
            exit 1
        fi
    else
        echo "Spark download failed, exiting"
        exit 1
    fi
else
    echo "Spark already installed, skipping download and install phase"
fi

# Need JDK to be able to run word counts with Hadoop.
echo "Checking if java is installed..."
if [[ $(java -version 2>&1) == *"OpenJDK"* ]]
then
    echo "OpenJDK Installed, skipping install"
else
    echo 'Open JDK not installed, installing...'
    sudo apt update
    sudo apt upgrade -y
    sudo apt-get install -y openjdk-${JAVA_VERSION}-jdk
fi

echo "Install complete! Please run wordcount-test.sh to test the installs."

