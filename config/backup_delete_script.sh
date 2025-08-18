backup_delete() {
    local info_file="$HOME/autoback/backup/info"
    local backup_dir="$HOME/autoback/backup"
    
    # Check if info file exists and has content
    if [[ ! -f "$info_file" ]]; then
        echo "❌ Info file doesn't exist: $info_file"
        echo "🔧 No backups have been created yet."
        return 1
    fi
    
    if [[ ! -s "$info_file" ]]; then
        echo "❌ No backup information found (info file is empty)."
        echo "📁 Checking for orphaned backup files..."
        ls -la "$backup_dir"/*.{tar.gz,gpg} 2>/dev/null || echo "   No backup files found"
        return 1
    fi
    
    echo "📋 Available backups:"
    echo "===================="
    # Display backups with numbers for easier selection
    local counter=1
    while IFS=':' read -r backup_name original_path; do
        if [[ -n "$backup_name" ]]; then
            local backup_file="$backup_dir/$backup_name"
            local file_size=""
            if [[ -f "$backup_file" ]]; then
                file_size=$(du -h "$backup_file" 2>/dev/null | cut -f1)
                echo "$counter. $backup_name (${file_size}) -> $original_path"
            else
                echo "$counter. $backup_name (❌ FILE MISSING) -> $original_path"
            fi
            ((counter++))
        fi
    done < "$info_file"
    
    if [[ $counter -eq 1 ]]; then
        echo "❌ No valid backups found in info file."
        return 1
    fi
    
    echo ""
    echo "Enter the backup filename to delete (include extension .tar.gz or .gpg):"
    read -e backup_name
    
    # Validate input
    if [[ -z "$backup_name" ]]; then
        echo "❌ No backup name entered."
        return 1
    fi
    
    # Check if backup exists in info file
    if ! grep -q "^$backup_name:" "$info_file"; then
        echo "❌ Backup '$backup_name' not found in backup records."
        echo "📝 Available backups:"
        cut -d':' -f1 "$info_file"
        return 1
    fi
    
    # Find the backup file
    local backup_file="$backup_dir/$backup_name"
    
    # Get backup info before deletion
    local original_path=$(grep "^$backup_name:" "$info_file" | cut -d':' -f2)
    
    echo "🗑️  Preparing to delete:"
    echo "   File: $backup_file"
    echo "   Original location: $original_path"
    
    if [[ -f "$backup_file" ]]; then
        local file_size=$(du -h "$backup_file" 2>/dev/null | cut -f1)
        echo "   Size: $file_size"
    else
        echo "   ⚠️  Warning: Backup file doesn't exist on disk"
    fi
    
    # Confirmation prompt
    echo ""
    read -p "Are you sure you want to delete this backup? (y/N): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        # Delete the backup file if it exists
        if [[ -f "$backup_file" ]]; then
            rm -f "$backup_file"
            if [[ $? -eq 0 ]]; then
                echo "✅ Backup file deleted: $backup_file"
            else
                echo "❌ Failed to delete backup file: $backup_file"
                return 1
            fi
        else
            echo "⚠️  Backup file didn't exist on disk: $backup_file"
        fi
        
        # Remove from info file (using different delimiter to avoid issues with paths)
        sed -i "\|^$backup_name:|d" "$info_file"
        
        if [[ $? -eq 0 ]]; then
            echo "✅ Backup record removed from info file"
            echo "🗑️  Deletion completed successfully"
        else
            echo "❌ Failed to remove backup record from info file"
            return 1
        fi
    else
        echo "🚫 Deletion cancelled"
        return 0
    fi
}