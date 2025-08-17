#!/bin/bash
#This script for automating backup of certain directory with notification service
shopt -s expand_aliases 
alias include="source"
include "$HOME/autoback/config/new_backup_script.sh"
while [ ture ]
do
	printf "Welcome to Autoback\n"	
	printf "1) Configure new backup\n"
	printf "2) Restore backup\n"
	printf "3) View backups\n"
	printf "4) Delete backup\n"
	printf "5) Exit\n"
	printf "Please choose an option:"
	read -e option
	case $option in 
		1) new_backup ;;
		2) ;;
		3) ;;
		4) ;;
		5) printf "Goodbye..\n" 
		break;;
		*) continue ;;
	esac
done




