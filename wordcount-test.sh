#!/bin/bash

# By: Ross MacDonald
# This script will test the current system with a hadoop and spark job to ensure
# that the system is properly configured to run hadoop and spark.

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

# Lets get the word count file from the Gutenberg project
echo "Checking for input word count file..."
if [ ! -f ./input/100.txt.utf-8 ]
then
    echo "Word count file not found, downloading..."
    mkdir input
    wget -q http://www.gutenberg.org/ebooks/100.txt.utf-8
    mv 100.txt.utf-8 ./input
fi

# Make sure that the spark script is in our working directory
echo "Checking for spark word count script"
if [ -f ./spark-wordcount.py ]
then
    echo "Found word count script, sending job to spark..."
    # Run the spark word count algorithm and redirect the output to a log file
    ./${SPARK_INSTALL_DIR}/bin/spark-submit ./spark-wordcount.py >./spark-log.txt 2>&1
    if [ $? -eq 0 ]
    then
        echo "Spark job completed successfully. Here's some sample output:"
        # Print the first 10 lines to the console
        head ./spark-output/part-00000 
    else
        echo "Spark job failed, check log for more information."        
    fi
fi

# Make sure that the java file is in our working directory
echo "Checking for hadoop word count java file"
if [ -f ./HadoopWordCount.java ]
then
    echo "Found word count java file, compiling it"
    # Run the Hadoop word count algorithm
 
    export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:jre/bin/java::")
    export HADOOP_CLASSPATH=${JAVA_HOME}/lib/tools.jar
  
    # Compile the java file
    ./${HADOOP_INSTALL_DIR}/bin/hadoop com.sun.tools.javac.Main HadoopWordCount.java
    if [ $? -ne 0 ]
    then
        echo "Hadoop compile failed, exiting"
        exit 1
    fi
    
    # Put the classes into a jar to allow us to send to hadoop
    jar cf wc.jar HadoopWordCount*.class
    if [ $? -ne 0 ]
    then
        echo "Hadoop jar failed, exiting"
        exit 1
    fi
   
    # Run the hadoop job and redirect output to a log file
    echo "Compile successful. Sending job to Hadoop..."
    ./hadoop-2.7.3/bin/hadoop jar wc.jar HadoopWordCount ./input/ ./hadoop-output/ >./hadoop-log.txt 2>&1

    if [ $? -eq 0 ]
    then
        echo "Hadoop job completed successfully. Here's some sample output:"
        # Sample the output to the console
        head ./hadoop-output/part-r-00000
    else
        echo "Hadoop job failed, check log for more information."
    fi
fi

