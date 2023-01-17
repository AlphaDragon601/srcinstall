#!/bin/bash

FILE="$1"

mkdir ~/wrk/

tar -xf $FILE -C ~/wrk/

echo "Please enter the following info: "
read -p "name of program: " prgm_name
read -p "version number: " ver_num
read -p "build system (default gnu make): " builder
builder=${builder:-make}
echo $builder

confLoc="/home/carson/programs.conf"
line_nums=""

searchResult=$( grep -c "\[${prgm_name}\]" $confLoc)
echo "searching $confLoc ..."
echo "found $prgm_name $searchResult times"

if [ $searchResult -eq 1 ];then
    greph -h -w "\[$prgm_name\]" $confLoc >> $line_nums #find the line number of this program in programs.conf for later
    echo "found on line $line_nums"
elif [ $searchResult -gt 1 ]; then
    echo "$prgm_name is listed multiple times, check config and try again"
else
    read -p "$prgm_name is not installed, would you like to install it? (y/n) " installYN
    echo $installYN
fi


if [ "$installYN" = "y" ];then
    echo "installing..."

    cd ~/wrk/*
    
    if [ "$builder" = "make" ];then
        #make -n
        ./configure && make && make install
    fi

    echo "[$prgm_name]" >> $confLoc
    echo $ver_num >> $confLoc
    echo $builder >> $confLoc

fi



rm -r ~/wrk/