#!/bin/bash

echo "import category orders start ..."

n=0
while IFS=, read -r ref category 
do
  echo "read from file: $ref, $category"
	if [ $n == 0 ]
	then
		echo "skip the first line"
	else
		url="http://localhost:3001/importBookCategoryOrder"
		echo "url: $url"
		curl --request POST $url --data-urlencode "ref=$ref"	--data-urlencode "category=$category"
		echo
	fi
	let n++
done < "$1"

echo "import category orders done."
