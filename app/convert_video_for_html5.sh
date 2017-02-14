#!/bin/bash

inputdir=$1
outputdir=${inputdir}/converted

echo "Make new dir $subdir"
mkdir ${outputdir}

# get the list of media files
inputlist=files.lst.txt
ls ${inputdir}/*.flv>$inputlist
cnt=$(cat $inputlist | wc -l) 

# iterate through all files and convert
j=1
for i in $(cat $inputlist); do
	printf "\n# Converting file %d/%d:\n" "$j" "$cnt" 
	
	b=$(basename $i)
	
	ffmpeg -i $i -acodec aac -strict experimental -ac 2 -ab 128k -vcodec libx264 -preset slow -f mp4 -crf 22  ${outputdir}/$b.mp4
	
	ffmpeg -i $i -c:v libvpx -pass 2 -f webm -b:v 400K -crf 10 -an -y ${outputdir}/$b.webm
	
	# screenshot at 10 seconds:
	ffmpeg -i $i -ss 00:10 -vframes 1 -r 1 -f image2 ${outputdir}/$b.jpg

	((j++))
done