source "$HOME/autoback/config/backup/compression_script.sh"
new_backup()
{
	printf "Enter Backup Directory:"
		read -e backup_dir
	printf "Enter backup name:"
		read -e backup_name
		printf "Encryption type\n"
		printf "1) With encryption\n"
		printf "2) Without encryption\n"
		printf "Enter an option:"
		read -e option
		if [ $option -eq 1 ]
		then
			printf "Enter password:"
			read -s -e pw
		fi
	# printf "Check for new backup after (in hours):"
    #     	read -e time
	# printf "Enter Email to Notify:"
	# 	read -e mail

	create_backup $backup_dir $backup_name $option $pw

	
}
