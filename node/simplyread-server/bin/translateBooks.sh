#!/bin/bash

echo "translate books start..."

url="http://localhost:3001/translateBooks"
echo "url: $url"
curl $url
echo

echo "translate books done."
