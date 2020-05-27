# --------------------------------------------------------------------

import argparse
import sys

# --------------------------------------------------------------------

program_name = sys.argv[0]
arguments = sys.argv[1:]

argv2 = ['--runner=DirectRunner',
        '--streaming',
        '--service_account=pocsom@gmail.com']

parser = argparse.ArgumentParser()
args1, known_args = parser.parse_known_args ()
options, arglist = parser.parse_known_args (sys.argv)
#pocs1 = vars (arglist)
pocs = parser.parse_args ()
print (arglist) 
#print (vars (arglist))

