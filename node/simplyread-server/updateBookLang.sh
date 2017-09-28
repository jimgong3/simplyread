#!/bin/bash

echo "update book lang start..."

url="http://localhost:3001/updateBookLang"
echo "url: $url"
curl $url
echo

echo "update book lang done."
