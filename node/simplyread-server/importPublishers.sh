#!/bin/bash

echo "import publishers start ..."
file="$1"
lang="$2"
echo "file: $file, lang: $lang"

n=0
while IFS=, read -r publisher 
do
	echo "read from file: $publisher"
	if [ $n == 0 ]
	then
		echo "skip header"
	else
		url="http://localhost:3001/importPublisher"
		echo "url: $url"
		curl --request POST $url --data-urlencode "publisher=$publisher"	--data-urlencode "lang=$lang"
		echo
	fi
	let n++
done < "$1"

echo "import publishers done."
