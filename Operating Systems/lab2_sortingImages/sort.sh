!/bin/bash
sortF=$1
finalF=$2
mkdir -p $finalF 
for i in $(find $sort -type f -name "*.jpg")
do
        #echo "found file $i"
        year=$(date -r $i +"%y")
        month=$(date -r $i +"%B")
        day=$(date -r $i +"%d")
        #echo "date of file in yy mm dd .format" 
        date -r $i +"%y %B %-d" 
        #moving file creating directory if it doesn't exists
        mkdir -p $finalF/$year/$month/$day
        #use cp in practise not mv 
        cp $i $finalF/$year/$month/$day
done
