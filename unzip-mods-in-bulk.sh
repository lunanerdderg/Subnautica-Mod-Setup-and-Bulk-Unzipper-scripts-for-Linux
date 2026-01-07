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
    for file in $subnauticaDirectory/BepInEx/plugins/*; do
        if [[ "${file}" = *".zip" ]] || [[ "${file}" = *".7z" ]] || [[ "${file}" = *".rar" ]] || [[ "${file}" = *".tar"* ]]; then
            echo "$file"
            mv "${file}" "${directory}/$(basename "${file}")"
        fi
    done
fi

temp_dir=$(mktemp -d)
trap 'rm -rf -- "$temp_dir"' EXIT
for file in $directory/*; do
    if [[ $file == *.zip ]] || [[ $file == *.7z ]] || [[ $file == *.rar ]] || [[ $file == *.tar* ]]; then
        safe="y"
        cd $directory
        if [[ "${file}" == *.zip ]]; then
            unzip "$file" -d "$temp_dir"
        elif [[ "${file}" == *.7z ]]; then
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
            elif [[ "${file}" == *.rar ]]; then
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
        elif [[ "${file}" == *.tar* ]]; then
            tar –xf "$file" -C "$temp_dir"
        fi
        if [ $safe = "y" ]; then
            cd $temp_dir
            pluginsFolder=$(find "$temp_dir" -type d -name "plugins" || echo "")
            configFolder=$(find "$temp_dir" -type d -name "config" || echo "")
            if [ -z "$pluginsFolder" ]; then
                for modFolder in *; do
                    find "${modFolder}" -type d -empty -print0 | while read -d $'\0' curFile; do
                        destination="$subnauticaDirectory/BepInEx/plugins/${curFile}"
                        if [ ! -d "${destination}" ]; then
                            mkdir -p "${destination}"
                        fi
                    done
                    find "${modFolder}" -type f -print0 | while read -d $'\0' curFile; do
                        destination="$subnauticaDirectory/BepInEx/plugins/${curFile}"
                        if [[ "${curFile}" =  *".structure" ]]; then
                            destination="$subnauticaDirectory/BepInEx/plugins/EpicStructureLoader/Structures/$(basename "${curFile}")"
                        fi
                        if [[ "${curFile}" =  *".txt" ]]; then
                            destination="$subnauticaDirectory/BepInEx/plugins/CustomCraft3/WorkingFiles/$(basename "${curFile}")"
                        fi
                        if [ ! -d "${destination%/*}" ]; then
                            mkdir -p "${destination%/*}"
                        fi
                        mv "${curFile}" "${destination}"
                    done
                done
            else
                for modFolder in "${pluginsFolder}"/*; do
                    find "${modFolder}" -type d -empty -print0 | while read -d $'\0' curFile; do
                        destination="$subnauticaDirectory/BepInEx/plugins/${curFile/$pluginsFolder\//}"
                        if [ ! -d "${destination}" ]; then
                            mkdir -p "${destination}"
                        fi
                    done
                    find "${modFolder}" -type f -print0 | while read -d $'\0' curFile; do
                        destination="$subnauticaDirectory/BepInEx/plugins/${curFile/$pluginsFolder\//}"
                        if [[ "${curFile}" =  *".structure" ]]; then
                            destination="$subnauticaDirectory/BepInEx/plugins/EpicStructureLoader/Structures/$(basename "${curFile}")"
                        fi
                        if [ ! -d "${destination%/*}" ]; then
                            mkdir -p "${destination%/*}"
                        fi
                        mv "${curFile}" "${destination}"
                    done
                done
            fi
            if [ ! -z "$configFolder" ]; then
                for modFolder in "${configFolder}"/*; do
                    find "${modFolder}" -type d -empty -print0 | while read -d $'\0' curFile; do
                        destination="$subnauticaDirectory/BepInEx/config/${curFile/$configFolder\//}"
                        if [ ! -d "${destination}" ]; then
                            mkdir -p "${destination}"
                        fi
                    done
                    find "${modFolder}" -type f -print0 | while read -d $'\0' curFile; do
                        destination="$subnauticaDirectory/BepInEx/config/${curFile/$configFolder\//}"
                        if [ ! -d "${destination%/*}" ]; then
                            mkdir -p "${destination%/*}"
                        fi
                        mv "${curFile}" "${destination}"
                    done
                done
            fi
            rm -rf "${temp_dir}/"*
        fi
    fi
done
rm -rf $temp_dir

echo "Done! All your mods should now be playable!"
