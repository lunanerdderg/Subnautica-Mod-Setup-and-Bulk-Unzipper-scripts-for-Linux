#!/bin/bash

directory=${1:-"--None"}
subnauticaDirectory=${2:-"$HOME/.local/share/Steam/steamapps/common/Subnautica"}
helpOrNot=${3:-"--None"}

if [ $directory = "-h" ] || [ $directory = "--help" ] || [ $subnauticaDirectory = "-h" ] || [ $subnauticaDirectory = "--help" ]; then
    echo
    echo "All listed parameters are optional, but must be used IN ORDER. If you want to use the second but not the first, use '-n' or '--None'"
    echo
    echo "Example: unzip-mods-in-bulk.sh -n directory/of/Subnautica"
    echo
    echo "    -h, --help: Show this help menu"
    echo "    1. Folder containing mod zips (defaults to 'Subnautica/BepInEx/plugins' folder)"
    echo "    2. Directory of Subnautica game folder"
    echo
    echo "Unlike 'install.sh', this script has no user prompts."
    echo
    exit 0
fi

if [ $directory = "-n" ] || [ $directory = "--None" ]; then
    directory=$(mktemp -d)
    if [ ! -d "$subnauticaDirectory" ]; then
        echo "Could not find Subnautica directory. Pass game folder as second argument."
        echo "(If you never passed a first argument, pass '--None', then directory.)"
        echo "(eg 'unzip-mods-in-bulk.sh --None <path/to/Subnautica>')"
        exit 1
    fi
    for file in $subnauticaDirectory/BepInEx/plugins/*
    do
        if [[ "${file}" = *".zip" ]] || [[ "${file}" = *".7z" ]] || [[ "${file}" = *".rar" ]] || [[ "${file}" = *".tar"* ]]; then
            mv "${file}" "${directory}/$(basename ${file})"
        fi
    done
fi

temp_dir=$(mktemp -d)
for file in $directory/*
do
    if [[ $file == *.zip ]] || [[ $file == *.7z ]] || [[ $file == *.rar ]] || [[ $file == *.tar* ]]; then
        echo "Safe"
        safe="y"
        cd $directory
        if [[ $file == *.zip ]]; then
            unzip "$file" -d "$temp_dir"
        elif [[ $file == *.7z ]]; then
            if ! command -v 7z >/dev/null 2>&1
            then
                echo
                echo
                echo
                echo "ERROR: No ability to decompress 7z. Please install 7zip"
                echo
                echo
                echo
                safe="n"
            else
                7z x "$file" -o"$temp_dir"
            fi
            elif [[ $file == *.rar ]]; then
            if ! command -v unrar >/dev/null 2>&1
            then
                echo
                echo
                echo
                echo "ERROR: No ability to decompress rar. Please install unrar or unrar-free"
                echo
                echo
                echo
                safe="n"
            else
                unrar x "$file" "$temp_dir"
            fi
        elif [[ $file == *.tar* ]]; then
            tar –xf "$file" -C "$temp_dir"
        fi
        if [ $safe = "y" ]; then
            cd $temp_dir
            if [ -d "BepInEx" ]; then
                for folder in BepInEx/*
                do
                    cd /
                    mv "${temp_dir}/${folder}" "${subnauticaDirectory}/${folder}"
                done
                rm -rf "$temp_dir/BepInEx"
            elif [ -d "BepInEx/plugins" ]; then
                for folder in BepInEx/plugins/*
                do
                    cd /
                    mv "${temp_dir}/${folder}" "${subnauticaDirectory}/${folder}"
                done
                rm -rf "$temp_dir/BepInEx"
            elif [ -d "plugins" ]; then
                for folder in plugins/*
                do
                    cd /
                    mv "${temp_dir}/${folder}" "${subnauticaDirectory}/BepInEx/${folder}"
                done
                rm -rf "$temp_dir/plugins"
            else
                for folder in *
                do
                    mv "${folder}" "${subnauticaDirectory}/BepInEx/plugins/${folder}"
                done
            fi
        fi
    fi
done
rm -rf "$temp_dir"
# cd $HOME
# if [ -d "$subnauticaDirectory/BepInEx/plugins/Tobey" ]; then
#     for file in "$subnauticaDirectory/BepInEx/plugins/Tobey/"*
#     do
#         echo
#         echo "$file"
#         echo
#         mv "$file" "${file/Tobey\//}"
#     done
#     rm -rf "$subnauticaDirectory/BepInEx/plugins/Tobey"
# fi

echo "Done! All your mods should now be playable!"
