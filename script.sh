#!/bin/bash


main_dir=/home/ubuntu

# Creating a folder if doesn't exist to keep log files in it.
mkdir -p $main_dir/summaryLogs

working_dir=$main_dir/summaryLogs

######### 1. Unusual\usual Accounts

copyUnusualAccountsLogs() {
	## Creating Logs File if it doesn't exist
	file_1=$working_dir/newUnusualAccounts
	test -f $file_1 || touch $file_1

	# Before: Get only the hash value of the log file
	local file_hash=`md5sum $file_1 | awk '{ print $1 }'`
	echo $file_hash
	
	
	# a. Finding all system Users
	all_users_accounts=`cut -d: -f1 /etc/passwd`
	
	# Get the account from "all_users_accounts" that doesn't exist in the file
	new_users=`grep -Fxvf $file_1 <(echo $all_users_accounts)`
	
	# Check if any new Users detected
	new_users_length=`echo ${#new_users}`
	
	# if there are new users, append new users to the file
	
	if [ $new_users_length -ne 0 ]
   	   then
       		(echo "Date:" && date && echo "") >> $file_1
		(echo "## Detected new System Accounts" && echo "" ) >> $file_1
		(grep -Fxvf $file_1 <(echo $all_users_accounts)) >> $file_1
	fi
	
	# After: Get only the hash value of the log file
	local n_file_hash=`md5sum $file_1 | awk '{ print $1 }'`
	echo $n_file_hash
	
	# Compare the old file hash value with the new one.
	if [ $file_hash != $n_file_hash ]
        then
                echo "New system users detected."
        else
                echo "No new system users are detected."
	fi
	
}

######### 2. Unusual log entries

copyUnusualEntriesLogs() {
	## Creating Logs File if it doesn't exist
	file_2=$working_dir/unusualLogs.txt
	test -f $file_2 || touch $file_2

	# Before:: Get only the hash value of the log file
	local file_hash=`md5sum $file_2 | awk '{ print $1 }'`
	echo $file_hash
	
	# a. Finding "authentication failure" Logs and storing them to tmp file
	grep 'authentication failure' /var/log/auth.log > $working_dir/tmp.txt
	
	new_failure_logs=`grep -Fxvf $file_2 $working_dir/tmp.txt`
	
	# Check if any new Users detected
	new_failure_logs_length=`echo ${#new_failure_logs}`

	# Printing current log file lines.
	echo "  Lines  | Words |Bytes"
	cat $file_2 | wc
	
	# O. Saving Logs to unusualLogs.txt
	if [ $new_failure_logs_length -ne 0 ] 
   	   then
       		(echo "Date:" && date && echo "") >> $file_2
       		# Take the new authentication failure lines and copy them to unusualLogs.
       		grep -Fxvf $file_2 $working_dir/tmp.txt >> $file_2
		
	fi
	# Printing new log file lines.
	cat $file_2 | wc
	
	# After:: Get only the hash value of the log file
	local n_file_hash=`md5sum $file_2 | awk '{ print $1 }'`
	echo $n_file_hash
	
	# Compare the old file hash value with the new one.
	if [ $file_hash != $n_file_hash ]
        then
                echo "New unusual system Logs detected."
        else
                echo "No unusual system Logs detected."
	fi
	
	# Remove the temporary file.
	sudo rm $working_dir/tmp.txt
	
}

######### 3. sluggish system performance 
copySystemPerformanceLogs() {
	
	# a. Showing Load Average and for how long the computer has been powered on
	load_avg=`uptime | grep -oP '(?=load).*'`
	up_time=`uptime -p`

	# b. Monitoring CPU, Device and Network file system utilization report
	cpu_state=`iostat`	

	# O. Saving Logs to systemPerformanceLogs.txt
	file_3=$working_dir/systemPerformanceLogs.txt
	test -f $file_3 || touch $file_3
	
	# Get current file Lines
	echo "  Lines  | Words |Bytes"
	cat $file_3 | wc
	
	(echo "Date:" && date && echo "") >> $file_3

	(echo "##############################" ) >> $file_3
	(echo "## System up time:") >> $file_3
	(echo "------------------------------" ) >> $file_3
	(echo "$up_time" && echo "" && echo "") >> $file_3

	(echo "##############################" ) >> $file_3
	(echo "## System Load Average:" ) >> $file_3
	(echo "------------------------------" ) >> $file_3
	(echo "Load Average Description:" && echo "First cell: load average over the last 1 minute" && echo "Second cell: load average over the last 5 minutes" && echo "Third cell: load average over the last 15 minutes") >> $file_3
	(echo "$load_avg" && echo "" && echo "" ) >> $file_3


	(echo "##############################" ) >> $file_3
	(echo "## CPU, Device and Network file system utilization:") >> $file_3
	(echo "------------------------------" ) >> $file_3
	(echo "$cpu_state" && echo "" && echo "" ) >> $file_3
	
	cat $file_3 | wc

}

######### 4. Excessive memory use
copyMemoryUsageLogs() {
	
	
	# a. Searching in log files for an "out of memory" error
	exc_memory_logs=`grep -i -r 'out of memory' /var/log/`

		
	# O. Saving Logs to unusualMemoryUsageLogs.txt
	
	## Creating Logs File if it doesn't exist
	file_4=$working_dir/unusualMemoryUsageLogs.txt
	test -f $file_4 || touch $file_4

	# Before:: Get only the hash value of the log file
	local file_hash=`md5sum $file_4 | awk '{ print $1 }'`
	echo $file_hash
	
	# a. Finding "out of memory" Logs and storing them to tmp file
	grep -i -r 'out of memory' /var/log/ > $working_dir/tmp.txt
	
	new_oom_logs=`grep -Fxvf $file_4 $working_dir/tmp.txt`
	
	# Check if any new "out of memory" errors are detected
	new_oom_logs_length=`echo ${#new_oom_logs}`

	# Printing current log file lines.
	echo "  Lines  | Words |Bytes"
	cat $file_4 | wc
	
	# O. Saving Logs to unusualMemoryUsageLogs.txt
	if [ $new_oom_logs_length -ne 0 ] 
   	   then
       		(echo "Date:" && date && echo "") >> $file_4
       		# Take the new 'out of memory' failure lines and copy them to unusualMemoryUsageLogs.txt
       		grep -Fxvf $file_4 $working_dir/tmp.txt >> $file_4
		
	fi
	# Printing new log file lines.
	cat $file_4 | wc
	
	# After:: Get only the hash value of the log file
	local n_file_hash=`md5sum $file_4 | awk '{ print $1 }'`
	echo $n_file_hash
	
	# Compare the old file hash value with the new one.
	if [ $file_hash != $n_file_hash ]
        then
                echo "New 'Out of Memory' errors Logs detected."
        else
                echo "No 'Out of Memory' errors Logs detected."
	fi
	
	# Remove the temporary file.
	sudo rm $working_dir/tmp.txt
}

######### 5. Decrease in Disk space
copyDiskSpaceLogs() {
	
	# a. Showing the amount of disk space used and available on Linux file systems  
	disk_state=`df`

	# O. Saving Logs to diskUsageLogs.txt
	file_5=$working_dir/diskUsageLogs.txt
	test -f $file_5 || touch $file_5
	
	
	# Printing current log file lines.
	echo "  Lines  | Words |Bytes"
	cat $file_5| wc
	
	(echo "Date:" && date && echo "") >> $file_5

	(echo "##############################" ) >> $file_5
	(echo "## Disk space Usage:") >> $file_5
	(echo "------------------------------" ) >> $file_5
	(echo "$disk_state" && echo "" && echo "") >> $file_5
	
	cat $file_5 | wc

}


######### 6. Unusual process and services
copyProcessLogs() {
	# a. Finding  processes with root (UID 0) privileges and storing their info to tmp file.
	(ps -U root -u root u) > $working_dir/tmp.txt

	
	# O. Saving Logs to processesLogs.txt
	
	## Creating Logs File if it doesn't exist
	file_6=$working_dir/processesLogs.txt
	test -f $file_6 || touch $file_6

	# Before:: Get only the hash value of the log file
	local file_hash=`md5sum $file_6 | awk '{ print $1 }'`
	echo $file_hash
	
	# Grep new lines from tmp file.
	new_rpp=`grep -Fxvf $file_6 $working_dir/tmp.txt`
	
	# Check if any new root privileged processes are detected
	new_rpp_length=`echo ${#new_rpp}`
	
	
	# Printing current log file lines.
	echo "  Lines  | Words |Bytes"
	cat $file_6 | wc
	
	
	# O. Saving Logs to processesLogs.txt
	if [ $new_rpp_length -ne 0 ] 
   	   then
       		(echo "Date:" && date && echo "") >> $file_6
       		# Take the new lines and copy them to unusualFilesLogs.txt.
       		grep -Fxvf $file_6 $working_dir/tmp.txt >> $file_6
		
	fi
	# Printing new log file lines.
	cat $file_6 | wc
	
	# After:: Get only the hash value of the log file
	local n_file_hash=`md5sum $file_6 | awk '{ print $1 }'`
	echo $n_file_hash
	
	# Compare the old file hash value with the new one.
	if [ $file_hash != $n_file_hash ]
        then
                echo "New root privileged processes are detected."
        else
                echo "No new root privileged processes are detected."
	fi
	
	# Remove the temporary file.
	sudo rm $working_dir/tmp.txt


}
#---------------------
######### 7. Unusual Files
copyUnusualFilesLogs() {
	

	# a. Finding unusual large files. Ex: files that are greater than 7 MegaBytes and storing their names to tmp file.
	(sudo find / -size +7M -type f -exec du -Sh {} +  | sort -rh > $working_dir/tmp.txt) 2> $working_dir/errors.txt

		
	# O. Saving Logs to unusualFilesLogs.txt
	
	## Creating Logs File if it doesn't exist
	file_7=$working_dir/unusualFilesLogs.txt
	test -f $file_7 || touch $file_7

	# Before:: Get only the hash value of the log file
	local file_hash=`md5sum $file_7 | awk '{ print $1 }'`
	echo $file_hash
	
	# Grep new lines from tmp file.
	new_ulf=`grep -Fxvf $file_7 $working_dir/tmp.txt`
	
	# Check if any new Large Files are detected
	new_ulf_length=`echo ${#new_ulf}`
	
	
	# Printing current log file lines.
	echo "  Lines  | Words |Bytes"
	cat $file_7 | wc
	
	# O. Saving Logs to unusualFilesLogs.txt
	if [ $new_ulf_length -ne 0 ] 
   	   then
       		(echo "Date:" && date && echo "") >> $file_7
       		# Take the new lines and copy them to unusualFilesLogs.txt.
       		grep -Fxvf $file_7 $working_dir/tmp.txt >> $file_7
		
	fi
	# Printing new log file lines.
	cat $file_7 | wc
	
	# After:: Get only the hash value of the log file
	local n_file_hash=`md5sum $file_7 | awk '{ print $1 }'`
	echo $n_file_hash
	
	# Compare the old file hash value with the new one.
	if [ $file_hash != $n_file_hash ]
        then
                echo "New Large Files > 7 megabyte  detected."
        else
                echo "No new Large Files > 7 megabyte detected."
	fi
	
	# Remove the temporary file.
	sudo rm $working_dir/tmp.txt
	
}

######### 8. Unusual network usage
copyNetworkUsageLogs() {
	
	# a. Finding port listeners and storing their info to tmp file.
	`netstat -nap > $working_dir/tmp.txt`

	# O. Saving Logs to networkUsageLogs.txt
	
	## Creating Logs File if it doesn't exist
	file_8=$working_dir/unusualNetworkUsageLogs.txt
	test -f $file_8 || touch $file_8

	# Before:: Get only the hash value of the log file
	local file_hash=`md5sum $file_8 | awk '{ print $1 }'`
	echo $file_hash
	
	# Grep new lines from tmp file.
	new_npl=`grep -Fxvf $file_8 $working_dir/tmp.txt`
	
	# Check if any new Network Port Listeners are detected
	new_npl_length=`echo ${#new_npl}`
	
	
	# Printing current log file lines.
	echo "  Lines  | Words |Bytes"
	cat $file_8 | wc
	
	# Saving Logs to networkUsageLogs.txt
	if [ $new_npl_length -ne 0 ] 
   	   then
       		(echo "Date:" && date && echo "") >> $file_8
       		# Take the new lines and copy them to unusualFilesLogs.txt.
       		grep -Fxvf $file_8 $working_dir/tmp.txt >> $file_8
		
	fi
	# Printing new log file lines.
	cat $file_8 | wc
	
	
	# b. Looking for promiscuous mode, which might indicate a sniffe 
	promiscuous_sniffer=`ip link | grep PROMISC`

	if [[ $promiscuous_sniffer -eq 0 ]] ; then
		(echo "No sniffers are discovered ")
	else
		(echo "$promiscuous_sniffer" && echo "" && echo "") >> $file_8
	fi 	
	
	
	
	# After:: Get only the hash value of the log file
	local n_file_hash=`md5sum $file_8 | awk '{ print $1 }'`
	echo $n_file_hash
	
	# Compare the old file hash value with the new one.
	if [ $file_hash != $n_file_hash ]
        then
                echo "New port Listeners are detected."
        else
                echo "No new port Listeners are detected."
	fi
	
	# Remove the temporary file.
	sudo rm $working_dir/tmp.txt
	
}

######## 9. Unusual scheduled tasks 
copyScheduledTasksLogs() {
	
	# a.  Finding cron jobs that are scheduled by root 
	#     Escaping the crontab file description 24 lines
	#     Then copy the cronjobs to tmp file.
	`(sudo crontab -u root -l | tail -n +24) > $working_dir/tmp.txt 2> $working_dir/errors.txt`

	# b. System-wide cron jobs
	`(ls /etc/cron.*) > $working_dir/tmp1.txt`
				
	
	# O. Saving Logs to unusualTasksLogs.txt
	
	## Creating Logs File if it doesn't exist
	file_9=$working_dir/unusualTasksLogs.txt
	test -f $file_9 || touch $file_9

	# Before:: Get only the hash value of the log file
	local file_hash=`md5sum $file_9 | awk '{ print $1 }'`
	echo $file_hash
	
	# Grep new lines from tmp file.
	new_utl_1=`grep -Fxvf $file_9 $working_dir/tmp.txt`
	
	# Grep new lines from tmp file.
	new_utl_2=`grep -Fxvf $file_9 $working_dir/tmp1.txt`
	
	# Get length of new_utl variables
	new_utl_1_length=`echo ${#new_utl_1}`
	new_utl_2_length=`echo ${#new_utl_2}`
	
	# Printing current log file lines.
	echo "  Lines  | Words |Bytes"
	cat $file_9 | wc
	
	# O. Saving Logs to unusualFilesLogs.txt
	if [ $new_utl_1_length -ne 0 ] || [ $new_utl_2_length -ne 0 ]
   	   then
       		(echo "Date:" && date && echo "") >> $file_9
		
	fi
	if [ $new_utl_1_length -ne 0 ] 
   	   then
       		# Root & UID:0 Cron Jobs:.
       		(echo "" && echo "###### Root Cron Jobss") >> $file_9
       		grep -Fxvf $file_9 $working_dir/tmp.txt >> $file_9
		
	fi
	if [ $new_utl_2_length -ne 0 ]
   	   then
       		#  System-wide cron jobs.
       		(echo "" && echo "###### System-wide cron jobs") >> $file_9
       		grep -Fxvf $file_9 $working_dir/tmp1.txt >> $file_9
		
	fi
	
	
	# Printing new log file lines.
	cat $file_9 | wc
	
	# After:: Get only the hash value of the log file
	local n_file_hash=`md5sum $file_9 | awk '{ print $1 }'`
	echo $n_file_hash
	
	# Compare the old file hash value with the new one.
	if [ $file_hash != $n_file_hash ]
        then
                echo "New cronjobs are detected."
        else
                echo "No new cronjobs are detected."
	fi
	
	# Remove the temporary file.
	sudo rm $working_dir/tmp.txt	
	sudo rm $working_dir/tmp1.txt			
				
	
}


## Calling the 9 Functions
(echo "-1-----Unusual Accounts Logs------")
copyUnusualAccountsLogs
(echo "" && echo "-2-----Unusual Entries Logs------")
copyUnusualEntriesLogs
(echo "" && echo "-3-----System Performance Logs------")
copySystemPerformanceLogs
(echo "" && echo "-4-----Unusual Memory Usage Logs------")
copyMemoryUsageLogs
(echo "" && echo "-5-----Disk Space Logs------")
copyDiskSpaceLogs
(echo "" && echo "-6-----Processes Logs------")
copyProcessLogs
(echo "" && echo "-7-----Large Files > 7M Logs ------")
copyUnusualFilesLogs
(echo "" && echo "-8-----Network Usage Logs------")
copyNetworkUsageLogs
(echo "" && echo "-9-----Scheduled Tasks Logs------")
copyScheduledTasksLogs




# Encrypting Files 

encryptSummaryLogsFiles() {
	# Getting the recipient name - gpg uses his Public Key
        recipient_name='Ahmed H. Ibrahim'

	# A tmp file to store log files names
	filesList=$working_dir/logfileslist.txt
	
	# Creating a Folder to hold encrypted log files
	en_folder=$main_dir/encryptedSummaryFiles
	mkdir -p $en_folder

	# Spacing
	echo "";echo ""; 

	# Getting name of the files from summaryLogs to a tmp file.
	`ls $working_dir/ > $filesList`

	# Iterating to encrypt each file
	for f in `cat $filesList`; 
	do 
		inFile=$working_dir/${f};
		outFile=$en_folder/${f}.gpg;
		
		if [ ${f} != 'logfileslist.txt' ]
		then
			#Encrypting the log file,Overwrite if exists
		     `sudo gpg --batch --yes -o $outFile -e -r 'Ahmed H. Ibrahim' $inFile 2> $working_dir/errors.txt`;

		fi
	done;

	# Removing the filesList temp file.
	`rm $filesList`	
}
encryptSummaryLogsFiles



