create_backup() {
    local source_path="$1"
    local backup_name="$2"
    local exclude_pattern="_info.txt"
    local use_encryption="$3"
    local password="$4"
    
    # Base tar command
    local tar_cmd="tar -czvf"
    
    if [[ "$use_encryption" == 1 ]]; then
        echo "Creating encrypted backup..."
        local backup_path="${HOME}/autoback/backup/${backup_name}.gpg"
        
        # Using GPG for encryption
        if command -v gpg >/dev/null 2>&1; then
            if [[ -n "$password" ]]; then
                tar -czvf - --exclude="$exclude_pattern" "$source_path" | \
                gpg --batch --yes --passphrase "$password" \
                    --symmetric --cipher-algo AES256 \
                    --compress-algo 1 --s2k-mode 3 \
                    --s2k-digest-algo SHA512 \
                    --s2k-count 65011712 \
                    --force-mdc \
                    --output "$backup_path"
            else
                tar -czvf - --exclude="$exclude_pattern" "$source_path" | \
                gpg --yes --symmetric --cipher-algo AES256 \
                    --compress-algo 1 --s2k-mode 3 \
                    --s2k-digest-algo SHA512 \
                    --s2k-count 65011712 \
                    --force-mdc \
                    --output "$backup_path"
            fi
            
            if [[ $? -eq 0 ]]; then
                echo "✅ Encrypted backup created: $backup_path"
                echo "$backup_name.gpg:$source_path" >> "$HOME/autoback/backup/info"
            else
                echo "❌ Failed to create encrypted backup"
                return 1
            fi
        else
            echo "❌ GPG not available for encryption"
            return 1
        fi
    else
        echo "Creating unencrypted backup..."
        local backup_path="${HOME}/autoback/backup/${backup_name}.tar.gz"
        
        tar -czvf "$backup_path" --exclude="$exclude_pattern" "$source_path"
        
        if [[ $? -eq 0 ]]; then
            echo "✅ Backup created: $backup_path"
            echo "$backup_name.tar.gz:$source_path" >> "$HOME/autoback/backup/info"
        else
            echo "❌ Failed to create backup"
            return 1
        fi
    fi
}
create_backup() {
    local source_path="$1"
    local backup_name="$2"
    local exclude_pattern="_info.txt"
    local use_encryption="$3"
    local password="$4"
    
    # Get the parent directory and target directory name
    local parent_dir=$(dirname "$source_path")
    local target_dir=$(basename "$source_path")
    
    # Store current directory to return to it later
    local original_dir=$(pwd)
    
    # Change to parent directory for relative path creation
    cd "$parent_dir" || {
        echo "❌ Cannot access parent directory: $parent_dir"
        return 1
    }
    
    if [[ "$use_encryption" == 1 ]]; then
        echo "Creating encrypted backup..."
        local backup_path="${HOME}/autoback/backup/${backup_name}.gpg"
        
        # Using GPG for encryption
        if command -v gpg >/dev/null 2>&1; then
            if [[ -n "$password" ]]; then
                tar -czvf - --exclude="$exclude_pattern" "$target_dir" | \
                gpg --batch --yes --passphrase "$password" \
                    --symmetric --cipher-algo AES256 \
                    --compress-algo 1 --s2k-mode 3 \
                    --s2k-digest-algo SHA512 \
                    --s2k-count 65011712 \
                    --force-mdc \
                    --output "$backup_path"
            else
                tar -czvf - --exclude="$exclude_pattern" "$target_dir" | \
                gpg --yes --symmetric --cipher-algo AES256 \
                    --compress-algo 1 --s2k-mode 3 \
                    --s2k-digest-algo SHA512 \
                    --s2k-count 65011712 \
                    --force-mdc \
                    --output "$backup_path"
            fi
            
            # Return to original directory
            cd "$original_dir"
            
            if [[ $? -eq 0 ]]; then
                echo "✅ Encrypted backup created: $backup_path"
                echo "$backup_name.gpg:$source_path" >> "$HOME/autoback/backup/info"
            else
                echo "❌ Failed to create encrypted backup"
                return 1
            fi
        else
            cd "$original_dir"
            echo "❌ GPG not available for encryption"
            return 1
        fi
    else
        echo "Creating unencrypted backup..."
        local backup_path="${HOME}/autoback/backup/${backup_name}.tar.gz"
        
        tar -czvf "$backup_path" --exclude="$exclude_pattern" "$target_dir"
        
        # Return to original directory
        cd "$original_dir"
        
        if [[ $? -eq 0 ]]; then
            echo "✅ Backup created: $backup_path"
            echo "$backup_name.tar.gz:$source_path" >> "$HOME/autoback/backup/info"
        else
            echo "❌ Failed to create backup"
            return 1
        fi
    fi
}