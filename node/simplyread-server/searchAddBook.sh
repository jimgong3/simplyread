#!/bin/bash

echo 'add book start'

n=0
while IFS=, read -r col1 col2 col3 
do
    echo "read from file: $col1, $col2, $col3"
	if [ $n == 0 ] 
	then 
		echo "skip the first line"
	else 
		echo "add new book: $n"
		url="http://localhost:3001/searchAddBook?isbn=$col1"
		echo "url: $url"
		curl $url
		echo
	fi
	let n++
done < "$1"

echo "search add book complete."