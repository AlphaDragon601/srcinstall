#!/bin/bash

FILE="$1"

mkdir ~/wrk/

tar -xf $FILE -C ~/wrk/

echo "Please enter the following info: "
read -p "name of program: " $prgm_name
read -p "version number: " $ver_num
read -p "makefile compiler (default gnu make): " $compiler
compiler=${compiler:-make}
#echo $compiler



rm -r ~/wrk/