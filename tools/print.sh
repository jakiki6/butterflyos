#!/bin/sh

echo -n > /tmp/out.txt

for i in $(find . -type f | grep -v .git | grep -v .lst | grep -v LICENSE); do
	echo "##########" $i "##########" >> /tmp/out.txt
	cat $i >> /tmp/out.txt
	echo >> /tmp/out.txt
	echo >> /tmp/out.txt
done

libreoffice --convert-to "pdf" /tmp/out.txt
