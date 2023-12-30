#!bin/bash

clean_files() {
    # Clean Up
    echo "Cleanup running"

    # Pass $credential_file as an argument
    clean_up=("Dockerfile" "container_init.sh" "$1")

    # Use an array to store filenames for deletion
    files_to_delete=()

    for file in "${clean_up[@]}"; do
        if [ -e "$file" ]; then
            files_to_delete+=("$file")
        fi
    done

    # Print generated files
    echo -e "Generated files:\n${files_to_delete[@]}"

    # Delete files
    if [ ${#files_to_delete[@]} -gt 0 ]; then
        rm -f "${files_to_delete[@]}"
        echo "Files deleted."
    else
        echo "No files to delete."
    fi
}