#!/bin/bash

# -------------------
# Seeeeeeeedstudio:
# -------------------
#
# Top Layer:        pcbname.GTL
# Top Solder Mask:  pcbname.GTS
# Top Silkscreen:   pcbname.GTO
# Bottom Layer:     pcbname.GBL
# Bottom Solder Mask: pcbname.GBS
# Bottom silkscreen: pcbname.GBO
# Board Outline:    pcbname.GML/GKO
# Drills:           pcbname.TXT
# Inner Layer:      pcbname.GL2(for 4 layer)
# Inner Layer:      pcbname.GL3(for 4 layer)
#
# ...So, it's identical to OSHPark except for the drills name. Cool.
#
#
# -------------------
# DirtyPCBs:
# -------------------
#
# GTO       Top Silkscreen (text)
# GTS       Top Soldermask (the 'green' stuff)
# GTL       Top Copper (conducting layer)
# GBL       Bottom Copper
# GBS       Bottom Soldermask
# GBO       Bottom Silkscreen
# GML/GKO/GBR  Board Outline (But note only the smallest extent is used)
# TXT       Routing and Drill (the holes and slots)
#
# ...So, also identical to OSHPark, mostly.
# Though, note that DirtyPCBs offer their own Eagle CAM file, 
# "dirt_cheap_dirty_boards.v1.cam", at
# http://dirtypcbs.com/about.php

VERSION="1.2"
THISFILE=`basename $0`
HELP=$(printf "
-----------------------------------------------------------------------
${THISFILE} version ${VERSION}:\n
#
# Converts from Eagle CAD GCODE output to the file naming conventions
# of any of several PCB fab services, and zips the appropriate files into
# a single archive.
#
# This script converts the output files from the OSHPark (BatchPCB) CAM file 
# for EagleCAD 7.2 or higher into GCODE layers and an Excellon drills file 
# that are named appropriately for OSHPark\'s PCB fab service, or one of
# a handful of other PCB fab services, if specified by the user. 
#  
# These names come from OSHPark\'s \"Eagle 7.2 and newer\" \"2 layer\" CAM file
# from http://docs.oshpark.com/design-tools/eagle/generating-custom-gerbers/ 
# 
# OSHPark doesn\'t set specs for a \"cream\" (solder paste) layer, so I\'ve 
# added a placeholder \"TCR\" abbreviation for that layer, just to address it.
# 
# At present OSHPark does allow users to upload EagleCAD files directly, 
# but I haven\'t tried it because I do a few non-standard things with my 
# boards and layers.
# 
# For those who wish to do other non-standard things (OSHPark mentions
# putting the copper layers on top for easier debugging, e.g.), this
# script might help you a bit.
# 
# The file accepts a command-line argument stub that must be the same across 
# all files of a given board Gerber file set.
# 
# To use this script, execute it with a command line argument of a layer name 
# without any abbreviation, e.g. 

${THISFILE} FortyTwo 

# or something similar. 
#
# Optionally, the user can include a second command-line argument and 
# specify whether the Excellon drills file uses OSHPark, SeeedStudio, or 
# DirtyPCBs Gerber file naming conventions.
#
# OSHPark:     -o
# SeeedStudio: -s
# DirtyPCBs:   -d
#
# Besides the obvious potential for different tolerances and
# other preferences or design rules among fab houses, the DirtyPCBs CAM file
# automatically formats the file name for their fab, cutting out the 
# work of renaming the files. 
#
# This script currently assumes you have  made your Gerbers with the OSHPark 
# CAM file. This assumption, or any random CAM file, may not produce acceptable
# results and only you are responsible for ensuring that the files work for the 
# fab to which you are sending the files.
#
# This script works on Mac OS X. It should work on Linux. If you're using it
# on Windows, then it's up to you to make it work. ;-)
#
# The usual disclaimers apply: I made this for myself. If you find it useful,
# great, but I didn't make this for any purpose other than my own, and thus
# you use it at your own risk and without any support from me.
#
# Jesse Hamner, 2015--2016
-----------------------------------------------------------------------
 
  
\n
")

# What's the minimum allowable number of parameters?
MINPARAMS=1

# Later the script will compress (zip) the files with the set of file names
# stored in this string variable:
ZIP=""

###########################################################
# Work with the command line arguments:
###########################################################

# check for arguments:
if [ ${MINPARAMS} -eq 1 ]
then
    PLURAL="argument"   # English majors write scripts, too...
else
    PLURAL="arguments"
fi

# (crudely) read arguments:

if [ $# -lt "$MINPARAMS" ]
then
  echo""
  echo "This script really needs at least $MINPARAMS command-line ${PLURAL}!"
fi

# check to see if there's something besides raw space in the argument:
if [ -n "$1" ]                  # Tested variable is quoted.
then
    echo "Parameter #1 is $1"   # Need quotes to escape the hash (#) symbol
    echo""
fi 

# Provide help if there's no argument:
if [ "$1" = "" ] 
then
    STUB="FortyTwo"
    printf '%s\n' "${HELP}"
    exit
else

# TODO -- note this sed doesn't work for "FILENAME.someotherdescription.QQQ"
    C=`echo $1 | sed 's/\.[a-zA-Z]\{0,3\}$//'`
    echo "Removing the file descriptor suffix gets: ${C}"
    Q=`echo ${C} | sed 's/\.[a-zA-Z0-9]*$//' `
    echo "Removing any file description following a period gets: ${Q}"
    STUB=${Q}
fi

# Does user want to specify a fab house?

if [ "$2" = "" ] 
then
    echo""
    echo "==================================================================="
    echo " No command line argument for drills file suffix. Assuming OSHPark."
    echo "==================================================================="
    echo""
    DRILLS="XLN"

#   LAYERS is the list of file names created by the OSHPark CAM file. 
#   SUFF is the list of file suffixes required by OSHPark's upload regime.
    LAYERS=(toplayer boardoutline bottomsilkscreen topsilkscreen \
bottomsoldermask topsoldermask bottomlayer tcream)
    SUFF=(GTL GKO GBO GTO GBS GTS GBL TCR )
    FAB="oshpark"
    fi

if [ "$2" = "-s" ]
then
    echo""
    echo "User selected SeeedStudio file suffix conventions."
    DRILLS="TXT"
#   LAYERS is the list of file names created by the OSHPark CAM file. 
#   SUFF is the list of file suffixes required by SeeedStudio's upload regime.
    LAYERS=(toplayer boardoutline bottomsilkscreen topsilkscreen \
bottomsoldermask topsoldermask bottomlayer tcream)
    SUFF=(GTL GKO GBO GTO GBS GTS GBL TCR )
    FAB="seeedstudio"
fi

if [ "$2" = "-o" ]
then
    echo""
    echo "User selected OSHPark file suffix conventions."
    DRILLS="XLN"

#   LAYERS is the list of file names created by the OSHPark CAM file. 
#   SUFF is the list of file suffixes required by OSHPark's upload regime.
    LAYERS=(toplayer boardoutline bottomsilkscreen topsilkscreen \
bottomsoldermask topsoldermask bottomlayer tcream)
    SUFF=(GTL GKO GBO GTO GBS GTS GBL TCR )
    FAB="oshpark"
fi

if [ "$2" = "-d" ]
then
    echo""
    echo "User selected DirtyPCBs (Dangerous Prototypes) file suffix conventions."
    DRILLS="TXT"

#   LAYERS is the list of file names created by the OSHPark CAM file. 
#   SUFF is the list of file suffixes required by DirtyPCBs's upload regime.
    LAYERS=(toplayer boardoutline bottomsilkscreen topsilkscreen \
bottomsoldermask topsoldermask bottomlayer tcream )
    SUFF=(GTL GKO GBO GTO GBS GTS GBL TCR )
    FAB="dirtypcbs"
fi

echo""
echo "Using ${STUB} for file names."
echo "Will use ${DRILLS} as the suffix for the Excellon drills file."
echo""

###########################################################
# Rename files and remove useless (gpi) files:
###########################################################

# could use `seq` here, but nah:
for ((i=0; i < ${#LAYERS[*]} ; i++)); do

    arg="${LAYERS[i]}"
    N="${STUB}.${arg}"
    M="${N}.${SUFF[i]}"
    O="${STUB}.${SUFF[i]}"
#     echo "${O}"

    ZIP="${ZIP} ${O}"

# Curse you, spaces in filenames...

    if [ -e "${N}.ger" ]
    then
        echo "Going to rename ${N}.ger to ${O};"
        mv "${N}.ger" "${O}"
    else
        echo "File ${N}.ger not found!"
        exit
    fi
    
    if [ -e "${N}.gpi" ]
    then
        echo "deleting file \"${N}.gpi\""
        rm "${N}.gpi"
    else
        echo""
        echo "No file ${N}.gpi to remove."
    fi
    echo""
done

# Seeedstudio/DirtyPCBs and OSHPark use different suffixes for the 
# Excellon drills file, and the CAM file names the stub differently too.

echo "Lastly, the drill files:"
D="${STUB}.drills.xln"
DRI="${STUB}.drills.dri"

if [ -e "${D}" ]
then 
    echo "Renaming ${D} to ${STUB}.${DRILLS}; "
    mv "${D}" "${STUB}.${DRILLS}"
else
    echo "No file ${D} to delete."
fi

if [ -e "${DRI}" ]
then
    echo "Removing ${DRI} "
    rm "${DRI}"
else
    echo "No file \"${DRI}\" to delete."
fi

echo""
echo "...Done."

###########################################################
# Now zip the files:
###########################################################

echo""
echo "Now to zip the files:"
ZIP="${ZIP} ${STUB}.${DRILLS} " # list of files to include
D="${STUB}.${FAB}.zip"          # name of compressed archive

# Remove existing ".old" backups (assumes user doesn't care about it):
echo "Looking for file ${D}..."

if [ -e "${D}.old" ]
then
    echo ""
    echo "Found ${D}.old -- removing it."
    rm "${D}.old"
fi

# Keep one generation of existing .zip files (probably created by this script)
if [ -e "${D}" ]
then 
    echo "Renaming ${D} to ${D}.old; "
    mv "${D}" "${D}.old"
fi

# Zip up the files
echo "zip ${D} ${ZIP}"
zip ${D} ${ZIP}

echo""
echo "Script finished."
echo "Your zip archive file should be ready for submission."
echo""
exit

#<EOF>
