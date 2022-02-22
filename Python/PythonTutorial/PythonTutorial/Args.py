# --------------------------------------------------------------------

import argparse
import sys

# --------------------------------------------------------------------

program_name = sys.argv[0]
arguments = sys.argv[1:]

argv2 = ['--runner=DirectRunner',
        '--streaming',
        '--service_account=pocsom@gmail.com']


# Instantiate the parser
parser = argparse.ArgumentParser(description='Optional app description')
# Required positional argument
parser.add_argument('pos_arg', type=int,
                    help='A required integer positional argument')
# Optional positional argument
parser.add_argument('opt_pos_arg', type=int, nargs='?',
                    help='An optional integer positional argument')
# Optional argument
parser.add_argument('--opt_arg', type=int,
                    help='An optional integer argument')
# Switch
parser.add_argument('--switch', action='store_true',
                    help='A boolean switch')
options, arglist = parser.parse_known_args (arguments)
args = parser.parse_args()

print("Argument values:")
print(args.pos_arg)
print(args.opt_pos_arg)
print(args.opt_arg)
print(args.switch)

if args.pos_arg > 10:
    parser.error("pos_arg cannot be larger than 10")

#exit (0) ;


args1, known_args = parser.parse_known_args ()

exit (0) ;
#pocs1 = vars (arglist)
#pocs = parser.parse_args ()
#print (arglist) 
#print (vars (arglist))

