# Hadoop sub-process example (not Hadoopy package)
import subprocess

# Constants
HDFS_DIR='/tmp'
HDFS_FILE_PATH='/tmp/hadoop_test.txt'
LOC_FILE_PATH='D:/hadoop_test.txt'

def run_cmd(args_list):
        print ('Running system command: {0}'.format(' '.join (args_list)))
        proc = subprocess.Popen (args_list, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        s_output, s_err = proc.communicate () # This executes the command
        s_return =  proc.returncode
        return s_return, s_output, s_err 

#Run Hadoop ls command in Python
(ret, out, err)= run_cmd (['hdfs', 'dfs', '-ls', HDFS_FILE_PATH])
lines = out.split('\n')

#Run Hadoop get command in Python
(ret, out, err)= run_cmd(['hdfs', 'dfs', '-get', HDFS_FILE_PATH, LOC_FILE_PATH])

#Run Hadoop put command in Python
(ret, out, err)= run_cmd(['hdfs', 'dfs', '-put', LOC_FILE_PATH, HDFS_FILE_PATH])

#Run Hadoop copyFromLocal command in Python
(ret, out, err)= run_cmd(['hdfs', 'dfs', '-copyFromLocal', LOC_FILE_PATH, HDFS_FILE_PATH])

#Run Hadoop copyToLocal command in Python
(ret, out, err)= run_cmd(['hdfs', 'dfs', '-copyToLocal', HDFS_FILE_PATH, LOC_FILE_PATH])

# hdfs dfs -rm -skipTrash /path/to/file/you/want/to/remove/permanently
#Run Hadoop remove file command in Python
(ret, out, err)= run_cmd(['hdfs', 'dfs', '-rm', HDFS_FILE_PATH])
(ret, out, err)= run_cmd(['hdfs', 'dfs', '-rm', '-skipTrash', HDFS_FILE_PATH])

#rm -r
#HDFS Command to remove the entire directory and all of its content from #HDFS.
#Usage: hdfs dfs -rm -r <path>

(ret, out, err)= run_cmd(['hdfs', 'dfs', '-rm', '-r', HDFS_DIR])
(ret, out, err)= run_cmd(['hdfs', 'dfs', '-rm', '-r', '-skipTrash', HDFS_DIR])

#Check if a file exist in HDFS
#Usage: hadoop fs -test -[defsz] URI

#Options:
#-d: f the path is a directory, return 0.
#-e: if the path exists, return 0.
#-f: if the path is a file, return 0.
#-s: if the path is not empty, return 0.
#-z: if the file is zero length, return 0.
#hadoop fs -test -e filename

hdfs_file_path = '/tmp'
cmd = ['hdfs', 'dfs', '-test', '-e', hdfs_file_path]
ret, out, err = run_cmd (cmd)
print (ret, out, err)
if ret:
    print('File does not exist')
