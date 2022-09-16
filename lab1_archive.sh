#!/bin/bash

## This script will archive the contents of a directory
# and then compress the archive file using zip.

## Zip is a compression and file packaging/archive utility.

## BEFORE using:
# in terminal: sudo/brew install zip

## INPUT:
# ./lab1_archive.sh <directory_name> <num_of_days>

## ADDITIONAL INFO:
# directory_name can be just a simple name^ without any path

# Check if there are variables inputed while calling this script
FOLDER=$1
DAYNUM=$2

# if there are no variables inputed, then take default one
if [ -z "$FOLDER" ]
then FOLDER=$(pwd)
fi

if [ -z "$DAYNUM" ]
then DAYNUM=1
fi

echo -e "\nFolder: $FOLDER"
echo -e "Num of days: $DAYNUM\n"

HOURS_NUM=$(($DAYNUM*24))

# get the basename of the folder (in case there was a path in input)
RAW_FOLDER=$(basename "$FOLDER")

# get a full path of the folder (in case there waw no path to folder in input)
FOLDER_FULL_PATH=$( find "$HOME" -type d -name "$RAW_FOLDER" 2>/dev/null )
#echo "$FOLDER_FULL_PATH"

# create the name of a new archive file
#NEW_ARCHIVE_NAME="$RAW_FOLDER"-$(date +%Y-%m-%d-%H-%M-%S)

for FLD in $FOLDER_FULL_PATH
do
    echo -e "\nFolder: $FLD"
    echo -e "Do you want to compress this folder? (y/n)\n"
    read COMPRESS

    if [ "$COMPRESS" == "y" ]
    then
        POINT_TIME=$(date -v-"$HOURS_NUM"H)
        # get day and time without time zone
        POINT_TIME=$(date -j -f "%a %b %d %T %Z %Y" "$POINT_TIME" "+%Y-%m-%d %H:%M:%S")
        FILES_TO_SAVE=()

        # get current date, add 24 hours and compare with date of creation of the files
        # by using this loop I`m trying to deal with spaces in file names`
        while read FILE 
        do
            # checking time of creation of the file 
            FILE_DATE=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$FILE")
            echo -e "\nFile_time: $FILE_DATE"
            echo "POINT_TIME: $POINT_TIME"

            # compare time of creation with point time
            if [[ "$FILE_DATE" < "$POINT_TIME" ]]
            then
                echo "$FILE"
                FILES_TO_SAVE+=("$FILE")
                I+=1
            else
                echo "File $FILE is newer than "$DAYNUM" days" >&2
            fi

        done < <(find "$FLD" -type f -name "*" 2>/dev/null)

        # create a new archive file 
        if [ -z "$FILES_TO_SAVE" ]
        then
            echo -e "\nThere are no files to save\n"
        else

            echo -e "\nDelete all files after compressing them? (y/n)\n"
            read DELETE

            # compress folder using zip and save it in the same folder (that was compressed)
            if [ "$DELETE" == "y" ]
            then
                echo -e "\nDeleting files...\n"
                zip -rm "$FLD"/"$RAW_FOLDER"-$(date +%Y-%m-%d-%H-%M-%S).zip "${FILES_TO_SAVE[@]}"
                #"$FLD"
            else
                echo -e "\nNot deleting files...\n"
                zip -r "$FLD"/"$RAW_FOLDER"-$(date +%Y-%m-%d-%H-%M-%S).zip "${FILES_TO_SAVE[@]}"
                #"$FLD"

            fi

            echo -e "\nZip files in folder:"
            ls "$FLD"/*\.zip
        fi
    fi
done