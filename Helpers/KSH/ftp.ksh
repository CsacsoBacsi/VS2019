#!/bin/ksh

. ${WET_PROFILE}/ut_functions.ksh

ut_journal "${MOD}" "*** JOB COMMENCED ***"

# Set local envars
typeset -i RC=0

ftp_ascii_put()
{
ftp -iv <<END
open ${REMOTE_SERVER}
lcd ${LOCAL_DIR}
cd ${REMOTE_DIR}
ascii
put $1 ${1}.transferring
rename ${1}.transferring ${1}
END
ut_chk_ftp
ut_exit_nonzero_rc $LINENO "Errors encountered" "Putting ascii file $1"
}

ftp_binary_put()
{
ftp -iv <<END
open ${REMOTE_SERVER}
lcd ${LOCAL_DIR}
cd ${REMOTE_DIR}
bin
put $1 ${1}.transferring
rename ${1}.transferring ${1}
END
ut_chk_ftp
ut_exit_nonzero_rc $LINENO "Errors encountered" "Putting binary file $1"
}

network_copy()
{

case $2 in
   BIN*)
      ut_journal ${MOD} "Network copy transfer mode is BIN. No change to file."
   ;;
   ASCII)
      ut_journal ${MOD} "Network copy transfer mode is ASCII. Converting to DOS format..."
      unix2dos -k -q $1
   ;;
   *)
      ut_journal ${MOD} "Unrecognized transfer mode for network copy. No change to file."
   ;;
esac

cp $1 $REMOTE_DIR/${1}
ut_exit_nonzero_rc $LINENO "Errors encountered" "Copying file ${1} to $REMOTE_DIR"
}

counter=0
start_time=$SECONDS

# Loop for 58 mins. Wake up every minute.
while [[ $counter ]]
do

#-------------------------------------------------------------------
# Loop through any files in the local directory and FTP or cp them
# to downstream systems.
#-------------------------------------------------------------------
cd $WET_DATA/out || ut_exit_nonzero_rc $LINENO "Failed to cd to \$WET_DATA/out"
for file in *.*
do


   #-------------------------------------------------------------------
   # Don't try and process anything if no files found
   #-------------------------------------------------------------------
   if [[ ${file} == '*.*' ]]
   then
      ut_journal ${MOD} "No files in ${WET_DATA}/out to transfer"
      break
   fi

   ut_journal ${MOD} "About to transfer file ${WET_DATA}/out/${file}"


   #-------------------------------------------------------------------
   # Get FTP details - remote server, local directory locations etc
   #-------------------------------------------------------------------
   ut_get_sql_value FTPPARAMS "SELECT wet_cnf.pkg_wet_utility.fn_get_output_system_details('$file') FROM dual"
   # CR:08/06/2011: Do not exit script, just simply move on to the next file in directory
   #ut_exit_nonzero_rc $LINENO "Errors encountered" "Looking for file $file in WET_DATA.REPORT_DETAIL_HISTORY"
   SQL_RC=$?
   if [[ $SQL_RC -ne 0 ]]
   then
       ut_journal ${MOD} "Error looking for file $file in WET_DATA.REPORT_DETAIL_HISTORY. File may not yet be complete."
       continue
   fi

   #-------------------------------------------------------------------
   # Split the pipe-delimited value into it's parts
   #-------------------------------------------------------------------
   OLDIFS=$IFS
   IFS='|'
   set -A params $FTPPARAMS
   IFS=$OLDIFS


   #-------------------------------------------------------------------
   # assign database value returned to envars. eval is to handle
   # the database returning the name of an envar.
   #-------------------------------------------------------------------
   REMOTE_SERVER=${params[0]}
   REMOTE_DIR=${params[1]}
   TRANSFER_TYPE=${params[2]}
   eval LOCAL_DIR=${params[3]}
   ARCHIVE_SUB_DIR=${params[4]}
   TRANSFER_MODE=${params[5]}

   # Strings returned from db by ut_get_sql_value seem to have non-printing
   # character (or space?) at the end so strip them off. Only this var affected
   # because it's the end of a single pipe-delimited string that's returned.
   TRANSFER_MODE=$(echo ${TRANSFER_MODE})



   #---------------------------------------------------------------------------
   # Default variables where appropriate
   #---------------------------------------------------------------------------
   LOCAL_DIR=${LOCAL_DIR:-${WET_DATA}/out}

   if [[ -z "${ARCHIVE_SUB_DIR}" ]]
   then
       ARCHIVE_SUB_DIR=${WET_DATA_ARCH}
   else
       ARCHIVE_SUB_DIR=${WET_DATA_ARCH}/${ARCHIVE_SUB_DIR}
   fi

   ut_journal ${MOD} "Transfer type is $TRANSFER_TYPE"
   ut_journal ${MOD} "Transfer mode is $TRANSFER_MODE"
   ut_journal ${MOD} "Remote machine is $REMOTE_SERVER"
   ut_journal ${MOD} "Remote directory is $REMOTE_DIR"
   ut_journal ${MOD} "Local directory is $LOCAL_DIR"
   ut_journal ${MOD} "Archive sub directory is $ARCHIVE_SUB_DIR"


   #---------------------------------------------------------------------------
   # Test values returned
   #---------------------------------------------------------------------------
   if [[ -z ${TRANSFER_TYPE} ]]
   then
       ut_journal ${MOD} "Error - the transfer type envar (TRANSFER_TYPE) is empty"
       ut_shell_event ${LINENO} 1 "Error - the transfer type envar (TRANSFER_TYPE) is empty"
       ut_leave 2
   fi

   if [[ ${TRANSFER_TYPE} == "FTP" && -z "${REMOTE_SERVER}" ]]
   then
       ut_journal ${MOD} "Error - the remote server envar (REMOTE_SERVER) cannot be empty for FTP transfers"
       ut_shell_event ${LINENO} 1 "Error - the remote server envar (REMOTE_SERVER) cannot be empty for FTP transfers"
       ut_leave 2
   fi

   if [[ ${TRANSFER_TYPE} == "FTP" && -z "${TRANSFER_MODE}" ]]
   then
       ut_journal ${MOD} "Error - the transferMode envar (TRANSFER_MODE) cannot be empty for FTP transfers"
       ut_shell_event ${LINENO} 1 "Error - the transferMode envar (TRANSFER_MODE) cannot be empty for FTP transfers"
       ut_leave 2
   fi

   if [[ ${TRANSFER_TYPE} == "NETWORK" && -z "${REMOTE_DIR}" ]]
   then
       ut_journal ${MOD} "Error - the remote dir envar (REMOTE_DIR) cannot be empty for NETWORK transfers"
       ut_shell_event ${LINENO} 1 "Error - the remote dir envar (REMOTE_DIR) cannot be empty for NETWORK transfers"
       ut_leave 2
   fi

   case "$TRANSFER_TYPE" in
      FTP)
        case $TRANSFER_MODE in
                 BIN*)
                    ftp_binary_put $file
                    ;;
                 ASCII)
                    ftp_ascii_put $file
                    ;;
                 *)
                    ut_shell_event ${LINENO} 1 "TransferMode of file ${file} to be FTPd is neither ASCII nor BIN"
                    ut_leave 2
                    ;;
        esac
      ;;
      NETWORK)
        network_copy $file $TRANSFER_MODE
        ;;
      *)
        ut_shell_event ${LINENO} 1 "file $file transfer type $TRANSFER_TYPE not in FTP or NETWORK"
        ut_leave 2
        ;;
   esac


   #-----------------------------------------------------------------
   # Compress and move the files to archive
   #-----------------------------------------------------------------
   CURR_TIMESTAMP=`date +"%d%m%Y_%H%M%S"`

   mv ${file} ${ARCHIVE_SUB_DIR}/${file}.${CURR_TIMESTAMP}
   ut_exit_nonzero_rc $LINENO "Errors encountered" "Archiving file ${WET_DATA}/out/${file}"

   gzip -9 -f ${ARCHIVE_SUB_DIR}/${file}.${CURR_TIMESTAMP}
   ut_exit_nonzero_rc $LINENO "Errors encountered" "Gzipping file ${WET_DATA}/out/${file}"

done

counter=$(($counter+1))
((elapsed=SECONDS-start_time))

if [[ $elapsed -gt 3480 ]]
then
    break
fi

# Sleep for a minute
sleep 60

done

ut_leave 0
