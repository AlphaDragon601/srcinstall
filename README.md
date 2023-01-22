# Source Install Organizer Script (please give name suggestions)

## Description:
 A shell script to log source installs. This tool works as a pseudo-package manager but instead of packages the script is entirely agnostic to tarballs (tar.gz and tar.xz tested). The current version only works on gnu make files but I plan to add more functionality. 

## Usage:
```
sudo ./installer.sh in <tarball>
sudo ./installer.sh del <program name>
```

## Config File:
This program works using a .conf file at the address given in variable `confLoc` at the top of the file. This file stores user logged data on the installed tarball in the format:
```
[nameofprogram]
versionNumber
makeFileBuilder (i.e make)
tarballName
```


## Goals:

- [ ] Tidy up code into more neat functions
- [x] List installed programs option
- [ ] aliases
- [ ] man page(?)
- [ ] possibly another script to automate adding builder options
- [ ] better error handling
- [ ] automate conf file and tar storage directory creation
- [ ] install tarballs in bulk


### Note: you need to edit the confLoc and TarStoreLoc variables at the top of the script for it to work
