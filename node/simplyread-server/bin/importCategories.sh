#!/bin/bash

echo "import categories  start ..."

n=0
while IFS=, read -r isbn title category col4 col5 col6
do
  echo "read from file: $isbn, $title, $category"
	if [ $n == 0 ]
	then
		echo "skip the first line"
	else
		#url="http://localhost:3001/assignBookCategory?isbn=$isbn&category=$category"
		url2="http://localhost:3001/assignBookCategory"
		echo "url: $url"
		curl --request POST $url2 --data-urlencode "isbn=$isbn"	--data-urlencode "category=$category"
		#curl -X POST -H "Content-Type: text/html; charset=UTF-8" --data-ascii "isbn=$isbn&category=$category" $url2
		echo
	fi
	let n++
done < "$1"

echo "import categories done, re-build categories..."
url2="http://localhost:3001/buildCategories"
echo "url2: $url2"
curl $url2
echo

echo "re-build categories done."
