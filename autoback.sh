#!/bin/bash
#This script for automating backup of certain directory with notification service
shopt -s expand_aliases 
alias include="source"
include "$HOME/autoback/config/new_backup_script.sh"
include "$HOME/autoback/config/restore_backup.sh"
include "$HOME/autoback/config/view_backups_script.sh"
include "$HOME/autoback/config/backup_delete_script.sh"
printf "Welcome to Autoback\n"	
while [ true ]
do

	printf "1) Configure new backup\n"
	printf "2) Restore backup\n"
	printf "3) View backups\n"
	printf "4) Delete backup\n"
	printf "5) Exit\n"
	printf "Please choose an option:"
	read -e option
	case $option in 
		1) new_backup 
			break;;
		2) restore_backup 
			break;;
		3) view_backups 
			break;;
		4) backup_delete 
			break;;
		5) printf "Goodbye..\n" 
			break;;
		*) 	printf "Enter a valid option.\n"
			continue ;;
	esac
done




