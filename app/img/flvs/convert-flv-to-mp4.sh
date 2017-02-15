#!/bin/bash

# Author: Peter Hentrich
# Purpose: Converts all FLV video files in the specified directory to MP4 format
# In: 0=script name, 1=input directory containing music files
#
# Rev:
# 27/10/2012 v0.1 Set "-strict experimental" option to allow skipping of errors  
# 28/10/2012 v1.0 Set "-b:a 64k" audio bit rate to prevent freezing during conversion
# 29/10/2012 v0.3 Set "-report" option for logging
# 31/10/2012 v1.0 Move all log files to separate directory and combine into 1 file
# 12/11/2012 v1.1 Output the video metadata to a separate file <metadata.csv>
# 13/11/2012 v1.2 Didn't need to "touch" log files. Log file is CSV format.

tmp1=tmp1
tmp2=tmp2
script=$(basename -s .sh $0)

# settings
inputlist=files.lst.txt
starttime=$(date +%s)
datestring=$(date +%y%m%d-%H%M%S)
subdir=MP4-$datestring
inputdir=$1
outputdir=${inputdir}/${subdir}
logdir=${outputdir}/log
convertlog=$logdir/"ffmpeg.log.txt"
scriptlog=$logdir/$script.csv
infolog=$logdir/metadata.csv
spacer="--------------------"

# create the output directory
echo "Make new dir $subdir"
mkdir ${outputdir}
mkdir ${logdir}

# clear the log files
:> $convertlog
:> $scriptlog

# get the list of media files
ls ${inputdir}/*.flv>$inputlist
cnt=$(cat $inputlist | wc -l) 

# directly copy any MP4 files
cp $inputdir/*.mp4 $outputdir/. 2>>$scriptlog

# set headers on log file
echo "Cnt,Video Codec,Audio Codec,Error,Input File" >>$scriptlog

# iterate through all files and convert
j=1
for i in $(cat $inputlist); do
	printf "\n# Converting file %d/%d:\n" "$j" "$cnt" 
	basename=$(basename -s .flv $i)

	# get the type of video codec
	ffmpeg -i $i 2>$tmp1
	#vtype=$(cat $tmp1 | grep Video | awk -F : '{printf("%s",$4)}' | awk -F , '{printf("%s",$1)}' | tr -d " ")
	vtype=$(cat $tmp1 | grep "Video:" | awk -F : '{printf("%s",$4)}' | cut -c2-5)
	atype=$(cat $tmp1 | grep "Audio:" | awk -F : '{printf("%s",$4)}' | cut -c2-4)

	# get detailed info
	vinfo=$(cat $tmp1 | grep "Video:" | awk -F ": " '{printf("%s",$3)}' | sed 's/^ *//')
	ainfo=$(cat $tmp1 | grep "Audio:" | awk -F ": " '{printf("%s",$3)}' | sed 's/^ *//')
	metadata=$(cat $tmp1 | grep "Stream")

	# convert video file to mp4
	# options: create log file, ignore stdin, discard corrupt frames on input, ignore errors, output 64k audio bit rate
	case $vtype in
	flv1) 
		ffmpeg -report -v info -nostdin -fflags discardcorrupt -i $i -strict experimental -c:v mpeg4 -b:a 64k ${outputdir}/${basename}.mp4 
		error=$?;;
	h264) 
		ffmpeg -report -v verbose -nostdin -fflags discardcorrupt -i $i -vcodec copy -acodec copy ${outputdir}/${basename}.mp4
		error=$?;;
	"")	
		error="ERROR01: Unrecognised file";;
	*)	
		error="INFO: Unable to process videos of type \"${vtype}\".";;
	esac

	#echo -e "\n${spacer}"
	printf "%d,%s,%s,%d,%s\n" "$j" "$vtype" "$atype" "$error" "$i" >>$scriptlog
	printf "%2d,%s,%s,%s\n" "$j" "$i" "$vinfo" "$ainfo" >>$infolog

	((j++))
done

# find out how long this program has been running
currtime=$(date +%s)
let diff=$(( ( (currtime-starttime)/60 ) +2 ))

# merge all the log files
find -E . -maxdepth 1 -mmin -$diff -regex "./ffmpeg-[0-9]{8}-[0-9]{6}.log" >$tmp2
mv $(<$tmp2) "$logdir"
awk 'BEGIN{i=1;} FNR==1 {printf("-------\n\n#File%d:\n",i); i++}{print}' $logdir/ffmpeg-*.log>$convertlog

# append txt to log filenames
for i in $logdir/*.log; do mv "${i}" "${i}.txt"; done

