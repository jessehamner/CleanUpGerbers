#!/usr/bin/python

import sys
import os
import re
import io
import argparse

# Just for the OSHPark abbreviations for now:

fileending=".gvp"
inputfilename="NONAME"
path="/you/need/to/declare/a/path"

colordict = [ \
        ["GBL", 1, "12850 38550 12850"], \
        ["GTL", 1, "12850 38550 12850"], \
        ["BCR", 1, "65535 41384 20091"], \
        ["GBS", 1, "63106 23721 55629"], \
        ["GTS", 1, "63106 23721 55629"], \
        ["TCR", 1, "22139 24808 65535"], \
        ["GBO", 1, "61287 61285 35400"], \
        ["GKO", 2, "0 48830 48830"], \
        ["GTO", 1, "65535 65535 65535"], \
        ["XLN", 2, "0 0 0"] \
        ]

header="(gerbv-file-version! \"2.0A\")\n"
layer=11
verbose=0


def parseOptions():
    """Reads the user's command-line input for determining what to call the \
file and the directory path location."""
    if (sys.argv[0] == ""):
        print("WARNING: you need to provide a filename for the output file.")
        sys.exit()

    parser=argparse.ArgumentParser(description='''makegvp.py; a python script that takes the Gerber files in a given directory and creates a default gerbv document layout, with a standard color palette for each layer.
''')

    parser.add_argument("-n", "--name", action='store', \
        dest="filestub", default="NONAME",
        help="provide a filename stub for each Gerber layer", metavar="FILE")

    parser.add_argument("-p", "--path", action='store', \
            dest="path", default="/Users/", 
            help="provide a file path for the directory where the \
Gerber files are found", metavar="PATH" ) 

    arguments = parser.parse_args()
    args = vars(arguments)
    
    print("Looks like the input filename argument is: %s" % str(args['filestub']))
    print("And the input path argument is: %s" % str(args['path']))

    return (args)


def fileCheck(path, filestub, suffix ): 
    """Check for path/file.suffix and return True if it is there."""
    fpath = str("%s/%s.%s" % (path, filestub, suffix) )
    try:
        if (os.path.isfile(fpath) is True):
            return True

    except:
        print("Error when testing for file %s. Halting" % fpath )
        sys.exit()

    return False

def makeFooter(namestub, path, verbose):
    """Print the footer."""
    linestring=str("(define-layer! -1 \
(cons 'filename \"%s/\")\
(cons 'visible #f)\
(cons 'color #(0 0 0)))\n" % path )
    linestring+=str("(set-render-type! 3)\n")
    return linestring

def oneLine (key, color, layer, namestub,verbose):
    """Print a basic line with some layer variations."""
    linestring=str("(define-layer! %d (cons 'filename \"%s.%s\")\
(cons 'visible #t)(cons 'color #(%s))" % 
( layer, namestub , key , color) )

    if (key is not "XLN"):
        linestring += ")\n"
    else:
        linestring += "(cons 'attribs (list (list 'autodetect 'Boolean 1) \
(list 'zero_supression 'Enum 0) \
(list 'units 'Enum 0) \
(list 'digits 'Integer 4))))\n"

    return linestring

# End of function descriptions

# parse arguments:
print("Parsing arguments.")
arguments = parseOptions()

inputfilename = arguments['filestub']
path = arguments['path']
path = re.sub('\/$','', path)

# Main loop starts here:

f=open(str("%s/%s.gvp" % (path, inputfilename) ), 'w')

f.write(header)
for k in range(0,len(colordict)):
    if (fileCheck(path, inputfilename, colordict[k][0] ) is True)  :
        pass
    else:
        layer=layer-1
        continue
        
    for i in range(0,colordict[k][1]):
        thisline = oneLine(colordict[k][0], colordict[k][2], 
                layer, inputfilename, verbose)
        f.write(thisline)
        layer=layer-1
        if (layer<0):
            layer==0

linestring=makeFooter(inputfilename, path, verbose)
f.write(linestring)

f.close()

#<EOF>
