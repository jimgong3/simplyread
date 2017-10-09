#!/bin/bash

echo 'build tags start'

url="http://localhost:3001/collectTags?pretty"
echo "url: $url"
curl $url
echo

echo "search add book complete."
