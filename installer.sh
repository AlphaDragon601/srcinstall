#!/bin/bash

FILE="$1"

mkdir ~/wrk/

tar -xf $FILE -C ~/wrk/

echo "Please enter the following info: "
read -p "name of program: " prgm_name
read -p "version number: " ver_num
read -p "makefile compiler (default gnu make): " compiler
compiler=${compiler:-make}
#echo $compiler


searchResult=$( grep -c "\[${prgm_name}\]" ~/programs.conf)

#echo $searchResult
if [ $searchResult -eq 1 ];then
    greph -h -w "\[${prgm_name}\]" ~/programs.conf >> $line_nums #find the line number of this program in programs.conf for later
elif [ $searchResult -gt 1 ]; then
    echo "${prgm_name} is listed multiple times, check config and try again"
else
    read -p "$prgm_name is not installed, would you like to install it? (y/n) " $installYN
fi

rm -r ~/wrk/