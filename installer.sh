#!/bin/bash


# change with user
confLoc="/home/carson/programs.conf" # the location of the config file storing info
TarStoreLoc="/home/carson/storedTars" # where installed files store tarballs



trap cleanup 1 2 3 6
cleanup()
{
  echo -e "\nRemoving temporary files..."
  rm -rf "$WrkDir"
  exit
}



installFxn() {
    WrkDir=$(mktemp -d)

    tar -xf $1 -C $WrkDir/

    echo "Please enter the following info: "
    read -p "name of program: " prgm_name


    

    searchResult=$( grep -c "\[${prgm_name}\]" $confLoc)
    echo "searching $confLoc ..."
    echo "found $prgm_name $searchResult times"


    if [ $searchResult -eq 1 ];then #update if found in config

        line_num=$(grep -n "\[$prgm_name\]" $confLoc | cut -d : -f 1)

        echo "found on line $line_num"
        read -p "Version Number of new Tarball: " NewVer_num

        ver_line=$(($line_num+1))
        make_line=$(($line_num+2))

        #echo $ver_line
        #echo $make_line

        ver_num=$(sed -n ${ver_line}p $confLoc)
        builder=$(sed -n ${make_line}p $confLoc)

        echo "found version: $ver_num"
        echo "found build tool: $builder"

        #echo "$ver_num :: $NewVer_num"


        if [[ "$NewVer_num" != "$ver_num" ]];then
            read -p "Version given was $NewVer_num , conf file shows $ver_num , would you like to install $NewVer_num instead? (y/n): " response

            if [ "$response" = "y" ];then
                echo "installing..."

                cd $WrkDir/*

                if [ "$builder" = "make" ];then
               
                ./configure && make && make install
                fi

                echo "uninstalling old..."

                uninstallFxn $prgm_name
                echo "complete"

            fi


        fi


        elif [ $searchResult -gt 1 ]; then #throw error if listed >1

        echo "$prgm_name is listed multiple times, check config and try again"

     else # if not in config, install it

        read -p "$prgm_name is not installed, would you like to install it? (y/n) " installYN

        read -p "version number: " ver_num
        read -p "build system (default gnu make): " builder
        builder=${builder:-make}
        #echo $builder  


        #echo $installYN

        ########installer:###########
            if [ "$installYN" = "y" ];then
            echo "installing..."

            cd $WrkDir/*
            
            if [ "$builder" = "make" ];then
            
                ./configure && make && make install
            fi

            realFile=$(readlink -f "$CmdDir/$1")


            cp $realFile $TarStoreLoc #store that tarball for uninstalling later

            echo "[$prgm_name]" >> $confLoc
            echo $ver_num >> $confLoc #version number then build tool
            echo $builder >> $confLoc
            echo $1 >> $confLoc

        fi
        #############################
    fi





    rm -r $WrkDir/

}



listFxn() {
    grep -n "\[" $confLoc
}


uninstallFxn() { # takes parameter 1 as program name to look for and uninstall

    line_num=$(grep -n "\[$1\]" $confLoc | cut -d : -f 1)

    if [ -n "$line_num" ];then

        echo "found on line $line_num"

        make_line=$(($line_num+2))

        builder=$(sed -n ${make_line}p $confLoc)

        echo "found build tool: $builder"

        path_line=$(($line_num+3))

        TarName=$(sed -n ${path_line}p $confLoc)
        
        echo "found tarball name: $TarName"

        cd $TarStoreLoc
        tar -xzf $TarName

        
        TarDir=$(echo ${TarName%???????})
        echo "extracted dir name: $TarDir"
        echo "$TarDir"
        cd $TarDir
        echo "entered"
        if [ "$builder" = "make" ];then
        ./configure && make uninstall
        cd ..
        rm -r $TarDir
        rm $TarName
        fi

        echo "removing from config..."

        ver_line=$(($line_num+1))

        sed -i ${path_line}d $confLoc
        sed -i ${make_line}d $confLoc
        sed -i ${ver_line}d $confLoc
        sed -i ${line_num}d $confLoc
        
        

        echo "removed"

        else
            echo "program not found, check config at $confLoc"

        fi
    

}



if [ "$1" = "in" ];then
    CmdDir=$(pwd)
    # inCmdCount=$(expr $# )
    # echo "$inCmdCount"
    shift
    for var in "$@"
    do
        cd $CmdDir
        echo -e "\n$var"
        installFxn $var
    done

elif [ "$1" = "del" ];then
    shift
    for var in "$@"
    do
        echo -e "\n$var"
        uninstallFxn $var
    done

elif [ "$1" = "lis" ];then
    listFxn
elif [ x"$1" = "x" ];then
    echo -e "no command entered, options are \n\tin \n\tdel \n\tlis"
else
    echo "command: $1 not found"

fi

