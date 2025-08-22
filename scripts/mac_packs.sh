#!/bin/bash

output_file="installed_packages.txt"

export_packages() {
    echo "Homebrew packages:" > "$output_file"
    brew leaves | xargs brew desc --eval-all >> "$output_file"
    echo "Package list saved to $output_file"
}

import_packages() {
    if [[ ! -f "$output_file" ]]; then
        echo "Error: $output_file not found."
        exit 1
    fi

    sed '1d' "$output_file" | while read -r line; do
        if [[ ! -z "$line" ]]; then
            package=$(echo "$line" | awk '{print $1}')
            if [[ ! -z "$package" ]]; then
                echo "Installing $package..."
                brew install "$package"
            fi
        fi
    done
}

case "$1" in
    "export")
        export_packages
        ;;
    "import")
        import_packages
        ;;
    *)
        echo "Usage: $0 {export|import}"
        exit 1
        ;;
esac

