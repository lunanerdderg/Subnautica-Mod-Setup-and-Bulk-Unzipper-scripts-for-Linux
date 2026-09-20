#!/bin/bash

# This is free and unencumbered software released into the public domain.

# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.

# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

# For more information, please refer to <https://unlicense.org/>

directory=${1:-"--None"}
subnauticaDirectory=${2:-"$HOME/.local/share/Steam/steamapps/common/Subnautica"}
extraArg=${3:-"--None"}

if [ $directory = "-h" ] || [ $directory = "--help" ] || [ $subnauticaDirectory = "-h" ] || [ $subnauticaDirectory = "--help" ] || [ $extraArg = "-h" ] || [ $extraArg = "--help" ]; then
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
        subnauticaDirectory="$HOME/.local/share/Steam/steamapps/common/Subnautica/"
        if [ ! -d "$subnauticaDirectory" ]; then
            subnauticaDirectory="$HOME/Games/Heroic/Subnautica/"
            if [ ! -d "$subnauticaDirectory" ]; then
                subnauticaDirectory="$HOME/.lutris/epic-games-store/drive_c/Program Files/Epic Games/Subnautica"
                if [ ! -d "$subnauticaDirectory" ]; then
                    echo ""
                    echo ""
                    echo ""
                    echo ""
                    echo ""
                    echo ""
                    echo "Could not find Subnautica directory. Pass game folder as second argument."
                    echo "(If you never passed a first argument, pass '--None', then directory.)"
                    echo "(eg 'unzip-mods-in-bulk.sh --None <path/to/Subnautica>')"
                    echo ""
                    echo "(Usually located at:)"
                    echo " Steam:"
                    echo "    $HOME/.local/share/Steam/steamapps/common/Subnautica/"
                    echo " Heroic:"
                    echo "    $HOME/Games/Heroic/Subnautica/"
                    echo " Lutris:"
                    echo "    $HOME/.lutris/epic-games-store/drive_c/Program Files/Epic Games/Subnautica"
                    exit 1
                fi
            fi
        fi
    fi
    sevenzip="y"
    rawr="y"
    if ! command -v 7z >/dev/null 2>&1; then
        sevenzip="n"
    fi
    if ! command -v unrar >/dev/null 2>&1; then
        rawr="n"
    fi
    for file in $subnauticaDirectory/BepInEx/plugins/*; do
        if [[ "${file}" = *".zip" ]] || [[ "${file}" = *".tar"* ]]; then
            echo "$file"
            mv "${file}" "${directory}/$(basename "${file}")"
        fi
        if [[ "${file}" = *".7z" ]] && [[ "${sevenzip}" = "y" ]]; then
            echo "$file"
            mv "${file}" "${directory}/$(basename "${file}")"
        fi
        if [[ "${file}" = *".rar" ]] && [[ "${rawr}" = "y" ]]; then
            echo "$file"
            mv "${file}" "${directory}/$(basename "${file}")"
        fi
    done
fi

temp_dir=$(mktemp -d)
trap 'rm -rf -- "$temp_dir"' EXIT
for file in $directory/*; do
    if [[ $file == *.zip ]] || [[ $file == *.7z ]] || [[ $file == *.rar ]] || [[ $file == *.tar* ]]; then
        dllsPresent="y"
        cd $directory
        if [[ "${file}" == *.zip ]]; then
            unzip "$file" -d "$temp_dir"
        elif [[ "${file}" == *.7z ]]; then
            7z x "$file" -o"$temp_dir"
        elif [[ "${file}" == *.rar ]]; then
            unrar x "$file" "$temp_dir"
        elif [[ "${file}" == *.tar* ]]; then
            tar –xf "$file" -C "$temp_dir"
        fi
        if [ "$(find "/home/luna/.local/share/Steam/steamapps/common/Subnautica/" -name "*.dll" | wc -m)" -eq 0 ]; then
            dllsPresent="n"
        fi
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
                    if [ $dllsPresent =  "n" ] && [[ "${curFile}" =  *".structure" ]]; then
                        destination="$subnauticaDirectory/BepInEx/plugins/EpicStructureLoader/Structures/$(basename "${curFile}")"
                    fi
                    if [ $dllsPresent =  "n" ] && [[ "${curFile}" =  *".txt" ]]; then
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
done
rm -rf $temp_dir

if ! command -v 7z >/dev/null 2>&1; then
    echo
    echo
    echo
    echo "ERROR: No ability to decompress 7z. Please install 7zip"
fi
if ! command -v unrar >/dev/null 2>&1; then
    echo
    echo
    echo
    echo "ERROR: No ability to decompress rar. Please install unrar or unrar-free"
fi

echo
echo
echo
echo "Done! All your mods should now be playable!"
