source "$HOME/autoback/config/restore/_restore_backup.sh"
restore(){
    printf "Available backups:\n"
    ls -l "$HOME/autoback/backup" 
    printf "Please enter the name of the backup to restore:"
    read -e backup_name
    _restore "$backup_name"
}
