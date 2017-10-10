#!/bin/bash
#
# Import list of books from a csv file.
# Arguments:
#	<arg1> filename

echo 'add books start...'
n=0
while IFS=, read -r isbn title category owner price
do
    echo "read from file: $isbn, $title, $category, $owner, $price"
	if [ $n == 0 ]
	then
		echo "skip the header"
	else
		echo "add new book: $n"
		url="http://localhost:3001/addBook"
		echo "url: $url"
		curl $url --request POST $url --data-urlencode "isbn=$isbn" --data-urlencode "title=$title" --data-urlencode "category=$category" --data-urlencode "owner=$owner" --data-urlencode "price=$price"
		echo
	fi
	let n++
done < "$1"
echo "add book complete."
echo 

echo "re-build tags start..."
url="http://localhost:3001/collectTags"
echo "url: $url"
curl $url
echo

echo "re-build categories start..."
url="http://localhost:3001/buildCategories"
echo "url: $url"
curl $url
echo

echo "done."
