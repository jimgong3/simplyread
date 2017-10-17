#!/bin/bash
#
# Import list of SF shopts from a csv file.
# Arguments:
#	<arg1> filename

echo 'add sf shops start...'
n=0
while IFS=, read -r type area sfid address 
do
    echo "read from file: $type, $area, $sfid, $address"
	if [ $n == 0 ]
	then
		echo "skip the header"
	elif [[ $type == \#* ]]
	  then
		echo "skip this line"
	  else
			echo "add new book: $area-$sfid"
			url="http://localhost:3001/addSfShop"
			echo "url: $url"
			curl $url --request POST --data-urlencode "type=$type" --data-urlencode "area=$area" --data-urlencode "sfid=$sfid" --data-urlencode "address=$address"
			echo
	fi
	let n++
done < "$1"
echo "add sf shops complete."
echo

echo "done."
