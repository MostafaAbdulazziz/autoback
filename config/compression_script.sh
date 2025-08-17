create_backup() {
    local source_path="$1"
    local backup_path="${HOME}/autoback/backup/$2"
    local exclude_pattern="_info.txt"
    local use_encryption="$3"
    local password="$4"
    
    # Base tar command
    local tar_cmd="tar -czvf"
    
    if [[ "$use_encryption" == "yes" ]]; then
        echo "Creating encrypted backup..."
        
        # Using GPG for encryption
        if command -v gpg >/dev/null 2>&1; then
            if [[  $password -eq 1 ]]; then
                tar -czvf - --exclude="$exclude_pattern" "$source_path" | \
                gpg --batch --yes --force --passphrase "$password" \
                    --symmetric --cipher-algo AES256 \
                    --compress-algo 1 --s2k-mode 3 \
                    --s2k-digest-algo SHA512 \
                    --s2k-count 65011712 \
                    --force-mdc \
                    --output "${backup_path}.gpg"
            else
                tar -czvf - --exclude="$exclude_pattern" "$source_path" | \
                gpg --force --symmetric --cipher-algo AES256 \
                    --compress-algo 1 --s2k-mode 3 \
                    --s2k-digest-algo SHA512 \
                    --s2k-count 65011712 \
                    --force-mdc \
                    --output "${backup_path}.gpg"
            fi
            
            if [[ $? -eq 0 ]]; then
                echo "✅ Encrypted backup created: ${backup_path}.gpg"
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
        tar -czvf "$backup_path" --exclude="$exclude_pattern" "$source_path"
        
        if [[ $? -eq 0 ]]; then
            echo "✅ Backup created: $backup_path"
        else
            echo "❌ Failed to create backup"
            return 1
        fi
    fi
}
