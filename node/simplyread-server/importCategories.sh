#!/bin/bash

echo "import categories  start ..."

declare -a arrayBookCategory
n=0
while IFS=, read -r isbn title category col4 col5 col6
do
  echo "read from file: $isbn, $title, $category"
	if [ $n == 0 ]
	then
		echo "skip the first line"
	else
		# echo "process new book: $n"
    declare "map_$isbn=$category"
    arrayBookCategory[$n]="$isbn:$category"
	fi
	let n++
done < "$1"

# echo ${arrayBookCategory[*]}

echo "review imported book categories ..."
for item in "${arrayBookCategory[@]}" ; do
  isbn="${item%%:*}"
  category="${item##*:}"
  printf "%s has category %s.\n" "$isbn" "$category"
done

echo "update database book categories records ..."

echo "import categories done"
