#!/bin/bash


# change with user
confLoc="/home/carson/programs.conf"
TarStoreLoc="/home/carson/storedTars"


installFxn() {

    mkdir ~/wrk/

    tar -xzf $FILE -C ~/wrk/

    echo "Please enter the following info: "
    read -p "name of program: " prgm_name


    

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
            echo $FILE >> $confLoc

        fi
        #############################
    fi





    rm -r ~/wrk/

}


uninstallFxn() {

    line_nums=$(grep -n "\[$prgm_name\]" $confLoc | cut -d : -f 1)

    echo "found on line $line_nums"

    make_line=$(($line_nums+2))

    builder=$(sed -n ${make_line}p $confLoc)

    echo "found build tool: $builder"

    path_line=$(($line_nums+3))

    TarName=$(sed -n ${path_line}p $confLoc)
    
    echo "found tarball name: $TarName"

    cd $TarStoreLoc
    tar -xzf $TarName

    
    TarDir=$(echo ${TarName%???????})
    echo "extracted dir name: $TarDir"
    cd $TarDir
    echo "entered"
    if [ "$builder" = "make" ];then
    ./configure && make uninstall
    fi

}



if [ "$1" = "in" ];then
    FILE=$2
    installFxn
elif [ "$1" = "del" ];then
    prgm_name=$2
    uninstallFxn


fi
