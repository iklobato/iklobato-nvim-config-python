#!/bin/bash

output_file="installed_packages.txt"

export_packages() {
    echo "Homebrew packages:" > $output_file
    brew leaves | xargs brew desc --eval-all >> $output_file

    echo "Package list saved to $output_file"
}

install_brew_packages() {
    while read -r line; do
        if [[ ! -z "$line" && "$line" != "Homebrew packages:" ]]; then
            package=$(echo "$line" | cut -d: -f1)
            brew install "$package"
        fi
    done
}

import_packages() {
    while IFS= read -r line; do
        case "$line" in
            "Homebrew packages:")
                install_brew_packages
                ;;
        esac
    done < "$output_file"
}

if [[ "$1" == "export" ]]; then
    export_packages
elif [[ "$1" == "import" ]]; then
    if [[ -f "$output_file" ]]; then
        import_packages
    else
        echo "Error: $output_file not found."
        exit 1
    fi
else
    echo "Usage: $0 {export|import}"
    exit 1
fi

