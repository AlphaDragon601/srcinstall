#!/bin/bash

FILE="$1"

mkdir ~/wrk/

tar -xf $FILE -C ~/wrk/

echo "Please enter the following info: "
read -p "name of program: " prgm_name


confLoc="/home/carson/programs.conf"
TarStoreLoc="/home/carson/storedTars"

searchResult=$( grep -c "\[${prgm_name}\]" $confLoc)
echo "searching $confLoc ..."
echo "found $prgm_name $searchResult times"





if [ $searchResult -eq 1 ];then

    line_nums=$(grep -n "\[$prgm_name\]" $confLoc | cut -d : -f 1)

    echo "found on line $line_nums"

    ver_line=$(($line_nums+1))
    make_line=$(($line_nums+2))

    #echo $ver_line
    #echo $make_line

    ver_num=$(sed -n ${ver_line}p $confLoc)
    builder=$(sed -n ${make_line}p $confLoc)

    echo "found version: $ver_num"
    echo "found build tool: $builder"



elif [ $searchResult -gt 1 ]; then

    echo "$prgm_name is listed multiple times, check config and try again"
    
else

    read -p "$prgm_name is not installed, would you like to install it? (y/n) " installYN

    read -p "version number: " ver_num
    read -p "build system (default gnu make): " builder
    builder=${builder:-make}
    #echo $builder  


    #echo $installYN

    ########installer:###########
        if [ "$installYN" = "y" ];then
        echo "installing..."

        cd ~/wrk/*
        
        if [ "$builder" = "make" ];then
            #make -n
            ./configure && make && make install
        fi

        cp $FILE $TarStoreLoc #store that tarball for uninstalling later

        echo "[$prgm_name]" >> $confLoc
        echo $ver_num >> $confLoc #version number then build tool
        echo $builder >> $confLoc


    fi
    #############################
fi












rm -r ~/wrk/