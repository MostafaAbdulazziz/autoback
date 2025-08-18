_restore() {
    local backup_file="$1"
    local restore_path=$(cat "$HOME/autoback/backup/info" | grep "$backup_file" | cut -d':' -f2)

    # Default restore path to current directory if not specified
    if [[ -z "$restore_path" ]]; then
        restore_path="$HOME/restored"
    fi
    
    # Create restore directory if it doesn't exist
    if [[ ! -d "$restore_path" ]]; then
        mkdir -p "$restore_path"
        echo "Created restore directory: $restore_path"
    fi
    
    # Check if backup file exists
    local backup_path="$HOME/autoback/backup/$backup_file"
    if [[ ! -f "$backup_path" ]]; then
        echo "❌ Backup file not found: $backup_path"
        return 1
    fi
    
    echo "Restoring backup from: $backup_file"
    echo "Restore location: $restore_path"
    
    # Determine file type and restore accordingly
    if [[ "$backup_file" == *.gpg ]]; then
        echo "Detected encrypted backup..."
        echo "Please enter the GPG password:"
        read -s -e password
        
        if command -v gpg >/dev/null 2>&1; then
            if [[ -n "$password" ]]; then
                # Simple extraction - no strip components needed now!
                gpg --batch --yes --passphrase "$password" --decrypt "$backup_path" | tar -xzvf - -C "$restore_path/.."
            else
                gpg --decrypt "$backup_path" | tar -xzvf - -C "$restore_path"
            fi
            
            if [[ $? -eq 0 ]]; then
                echo "✅ Encrypted backup restored successfully to: $restore_path/.."
                sed -i "\|$backup_file|d" "$HOME/autoback/backup/info"
                rm -rf "$backup_path"
            else
                echo "❌ Failed to restore encrypted backup"
                return 1
            fi
        else
            echo "❌ GPG not available for decryption"
            return 1
        fi
        
    elif [[ "$backup_file" == *.tar.gz ]]; then
        echo "Detected unencrypted backup..."
        
# Simple extraction - no strip components needed now!
        tar -xzvf "$backup_path" -C "$restore_path/.."
        
        if [[ $? -eq 0 ]]; then
            echo "✅ Backup restored successfully to: $restore_path/.."
            sed -i "/$backup_file/d" "$HOME/autoback/backup/info"
            rm -rf "$backup_path"
        else
            echo "❌ Failed to restore backup"
            return 1
        fi
    else
        echo "❌ Unknown backup file format: $backup_file"
        echo "Supported formats: .gpg (encrypted) or .tar.gz (unencrypted)"
        return 1
    fi
}