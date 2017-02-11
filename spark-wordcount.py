# This is a simple spark word count example

from pyspark import SparkContext
import re

def removePunctuation(text):
	return re.sub('[^a-z| |0-9]', '', text.strip().lower())

sc = SparkContext("local", "Simple App")
text_file = sc.textFile("./input/100.txt.utf-8")
counts = text_file.flatMap(lambda line: line.split(" ")) \
	.filter(lambda word: word != '') \
	.map(removePunctuation) \
	.filter(lambda a: len(a) > 7) \
	.map(lambda word: (word, 1)) \
	.reduceByKey(lambda a, b: a + b, 1) \
	.map(lambda a: (a[1], a[0])) \
	.sortByKey(False) \
	.map(lambda a: (a[1], a[0]))
counts.saveAsTextFile("spark-output")

