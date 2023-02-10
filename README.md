# Source Install Organizer Script (please give name suggestions)

## Description:
 A shell script to log source installs. This tool works as a pseudo-package manager but instead of packages the script is entirely agnostic to tarballs (tar.gz and tar.xz tested). The current version only works on gnu make files but I plan to add more functionality. 

## Usage:
```
sudo srcinstall in <tarball>
sudo srcinstall del <program name>
sudo srcinstall set /path/to/script/installer.sh
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
- [x] aliases
- [ ] man page(?)
- [ ] possibly another script to automate adding builder options
- [x] better error handling
- [x] automate conf file and tar storage directory creation
- [x] install tarballs in bulk
- [ ] support configure flags


### Note: config files and directory creation has been automated :)
### Note2: make sure to run "set" command on first run
