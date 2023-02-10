#!/bin/bash
user=$(logname)
confLoc="/home/$user/.config/srcinstaller/programs.conf"  # the location of the config file storing info
TarStoreLoc="/home/$user/.config/srcinstaller/storedTars" # where installed files store tarballs

isNoInput() {
    if [ "$1" == "" ]; then
        echo "please answer in accordance with the prompt...exiting"
        exit
    fi
}

setupFxn() {

    if [ "$1" == "" ]; then
        echo "enter the path of the script after the 'set' option"
        exit
    fi

    if [ ! -f "$1" ]; then
        echo "$1 is not a valid file"
        exit
    fi

    # check for conf and tarstore directories

    if [ ! -d "/home/$user/.config/srcinstaller/" ]; then
        mkdir /home/$user/.config/srcinstaller
    fi

    if [ ! -f "$confLoc" ]; then
        read -p "error: config file not found, would you like to create one at .config/srcinstaller/programs.conf? (y/n) " answer1
        if [ "$answer1" == "y" ]; then
            isNoInput $answer1
            touch /home/$user/.config/srcinstaller/programs.conf
        fi
    fi

    if [ ! -d "$TarStoreLoc" ]; then
        read -p "error: no tar storage dir, would you like to create one at .config/srcinstaller/storedTars/? (y/n)" answer2
        if [ "$answer2" == "y" ]; then
            isNoInput $answer2
            mkdir /home/$user/.config/srcinstaller/storedTars
        fi
    fi

    aliasCheck=$(grep -c "installer.sh" /home/$user/.bashrc)
    if [ $aliasCheck -eq 0 ]; then
        read -p "you don't have an alias for this installer, would you like to add one? (y/n) " answer3
        isNoInput $answer3
        if [ "$answer3" = "y" ]; then

            if [ $(grep -c "alias sudo='sudo '" /home/$user/.bashrc) -eq 0 ]; then
                echo "alias sudo='sudo '" >>/home/$user/.bashrc
            fi
            InputPath=$(readlink -f "$1")
            echo "alias srcinstall=\"$InputPath\"" >>/home/$user/.bashrc

        fi
    fi

}

trap cleanup 1 2 3 6
cleanup() {
    echo -e "\nRemoving temporary files..."
    rm -rf "$WrkDir"
    exit
}

installFxn() {
    WrkDir=$(mktemp -d)

    InputFile=$1

    InputfileName=$(basename ${1})
    InputfilePath=$(readlink -f $InputFile)
    StoredTarFile="$TarStoreLoc/$InputfileName"


    tar -xf $1 -C $WrkDir/



    echo "Please enter the following info: "
    read -p "name of program: " prgm_name
    isNoInput $prgm_name

    echo "searching $confLoc ..."
    searchResult=$(grep -c "\[${prgm_name}\]" $confLoc)
    echo "found $prgm_name $searchResult times"

    if [ $searchResult -eq 1 ]; then #update if found in config

        line_num=$(grep -n "\[$prgm_name\]" $confLoc | cut -d : -f 1)

        echo "found on line $line_num"
        read -p "Version Number of new Tarball: " NewVer_num
        isNoInput $NewVer_num

        ver_line=$(($line_num + 1))
        make_line=$(($line_num + 2))

        #echo $ver_line
        #echo $make_line

        ver_num=$(sed -n ${ver_line}p $confLoc)
        builder=$(sed -n ${make_line}p $confLoc)

        echo "found version: $ver_num"
        echo "found build tool: $builder"

        #echo "$ver_num :: $NewVer_num"

        if [[ "$NewVer_num" != "$ver_num" ]]; then
            read -p "Version given was $NewVer_num , conf file shows $ver_num , would you like to install $NewVer_num instead? (y/n): " response
            isNoInput $response
            if [ "$response" = "y" ]; then
                echo "installing..."

                cd $WrkDir/*

                if [ "$builder" = "make" ]; then

                    ./configure && make && make install
                fi

                echo "uninstalling old..."

                uninstallFxn $prgm_name
                echo "complete"

            fi

        fi

    elif  [ $searchResult -gt 1 ]; then #throw error if listed >1

        echo "$prgm_name is listed multiple times, check config and try again"

    else # if not in config, install it

        read -p "$prgm_name is not installed, would you like to install it? (y/n) " installYN

        read -p "version number: " ver_num
        read -p "build system (default gnu make): " builder
        builder=${builder:-make}

        isNoInput $installYN
        isNoInput $ver_num
        isNoInput $builder
        ########installer:###########

        if [ "$installYN" = "y" ]; then
            echo "installing..."

            cd $WrkDir/*

            if [ "$builder" = "make" ]; then

                ./configure && make && make install
            fi
            
            # echo $InputfilePath
            # echo $StoredTarFile

            if [ ! -f "$StoredTarFile" ];then

                cp $InputfilePath $StoredTarFile #store that tarball for uninstalling later

            else
                echo "Tar already stored"

            fi

            echo "[$prgm_name]" >>$confLoc
            echo $ver_num >>$confLoc #version number then build tool
            echo $builder >>$confLoc
            echo $InputfileName >>$confLoc

        else

            exit

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

    if [ -n "$line_num" ]; then

        echo "found on line $line_num"

        make_line=$(($line_num + 2))

        builder=$(sed -n ${make_line}p $confLoc)

        echo "found build tool: $builder"

        path_line=$(($line_num + 3))

        TarName=$(sed -n ${path_line}p $confLoc)
        TarName=$(basename ${TarName})
        echo "found tarball name: $TarName"

        read -p "are you sure you want to uninstall $1? (y/n): " confirmation

        if [ "$confirmation" = "y" ];then

            cd $TarStoreLoc
            tar -xzf $TarName

            TarDir=$(echo ${TarName%???????})
            echo "extracted dir name: $TarDir"
            echo "$TarDir"
            cd $TarDir
            echo "entered"
            if [ "$builder" = "make" ]; then
                ./configure && make uninstall
                cd ..
                rm -r $TarDir
                echo -e "\n\n\n\n"
                read -p "would you like to remove the stored tarball? (y/n)" answer
                isNoInput $answer
                if [ "$answer" == "y" ]; then
                    rm $TarName
                fi
            fi

            echo "removing from config..."

            ver_line=$(($line_num + 1))

            sed -i ${path_line}d $confLoc
            sed -i ${make_line}d $confLoc
            sed -i ${ver_line}d $confLoc
            sed -i ${line_num}d $confLoc

            echo "removed"
        
        else
            echo "cancelling..."
            exit

        fi

    else
        echo "program not found, check config at $confLoc"

    fi

}

if [ "$1" = "in" ]; then
    CmdDir=$(pwd)
    # inCmdCount=$(expr $# )
    # echo "$inCmdCount"
    shift
    for var in "$@"; do
        cd $CmdDir
        echo -e "\n$var"
        installFxn $var
    done

elif [ "$1" = "del" ]; then
    shift
    for var in "$@"; do
        echo -e "\n$var"
        uninstallFxn $var
    done

elif [ "$1" = "lis" ]; then
    listFxn
elif [ "$1" = "set" ]; then
    shift
    setupFxn $1
elif [ x"$1" = "x" ]; then
    echo -e "no command entered, options are \n\tin \n\tdel \n\tlis"
else
    echo "command: $1 not found"

fi
