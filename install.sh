#!/bin/bash

changedDirectory="n"
subnauticaDirectory="$HOME/.local/share/Steam/steamapps/common/Subnautica/"
ARG1=${1:-"--None"}
ARG2=${2:-"--None"}
ARG3=${3:-"--None"}
ARG4=${4:-"--None"}
ARG5=${5:-"--None"}

if [ $ARG1 = "-h" ] || [ $ARG1 = "--help" ] || [ $ARG2 = "-h" ] || [ $ARG2 = "--help" ] || [ $ARG3 = "-h" ] || [ $ARG3 = "--help" ] || [ $ARG4 = "-h" ] || [ $ARG4 = "--help" ] || [ $ARG5 = "-h" ] || [ $ARG5 = "--help" ]; then
    echo "Every listed parameter is optional, and may be used in any order."
    echo
    echo "    -h, --help               Display this guide"
    echo "    path/to/directory        Use path as Subnautica game directory"
    echo "    -n, --no-tweaks          Do not install Toebeann's BepInEx Tweaks for Subnautica"
    echo "    -t, --terrain-patcher    Install Esper89's Terrain Patcher mod"
    echo "    -d, --disable-autoopen   Do not open Subnautica automatically. Allow user to do it manually instead"
    echo "    -i, --ignore-prompt      Disable most user prompts (do not use if first time running)"
    exit 0
fi

if [ $ARG1 != "-"* ]; then
    subnauticaDirectory=$ARG1
    changedDirectory="y"
elif [ $ARG2 != "-"* ]; then
    subnauticaDirectory=$ARG2
    changedDirectory="y"
elif [ $ARG3 != "-"* ]; then
    subnauticaDirectory=$ARG3
    changedDirectory="y"
elif [ $ARG4 != "-"* ]; then
    subnauticaDirectory=$ARG4
    changedDirectory="y"
elif [ $ARG5 != "-"* ]; then
    subnauticaDirectory=$ARG5
    changedDirectory="y"
fi
if [ $ARG1 = "-n" ] || [ $ARG1 = "--no-tweaks" ] || [ $ARG2 = "-n" ] || [ $ARG2 = "--no-tweaks" ] || [ $ARG3 = "-n" ] || [ $ARG3 = "--no-tweaks" ] || [ $ARG4 = "-n" ] || [ $ARG4 = "--no-tweaks" ] || [ $ARG5 = "-n" ] || [ $ARG5 = "--no-tweaks" ]; then
    tweaks="n"
else
    tweaks="y"
fi
if [ $ARG1 = "-t" ] || [ $ARG1 = "--terrain-patcher" ] || [ $ARG2 = "-t" ] || [ $ARG2 = "--terrain-patcher" ] || [ $ARG3 = "-t" ] || [ $ARG3 = "--terrain-patcher" ] || [ $ARG4 = "-t" ] || [ $ARG4 = "--terrain-patcher" ] || [ $ARG5 = "-t" ] || [ $ARG5 = "--terrain-patcher" ]; then
    terrainPatcher="y"
else
    terrainPatcher="n"
fi
if [ $ARG1 = "-i" ] || [ $ARG1 = "--ignore-prompt" ] || [ $ARG2 = "-i" ] || [ $ARG2 = "--ignore-prompt" ] || [ $ARG3 = "-i" ] || [ $ARG3 = "--ignore-prompt" ] || [ $ARG4 = "-i" ] || [ $ARG4 = "--ignore-prompt" ] || [ $ARG5 = "-i" ] || [ $ARG5 = "--ignore-prompt" ]; then
    ignorePrompt="y"
else
    ignorePrompt="n"
fi
if [ $ARG1 = "-d" ] || [ $ARG1 = "--disable-autoopen" ] || [ $ARG2 = "-d" ] || [ $ARG2 = "--disable-autoopen" ] || [ $ARG3 = "-d" ] || [ $ARG3 = "--disable-autoopen" ] || [ $ARG4 = "-d" ] || [ $ARG4 = "--disable-autoopen" ] || [ $ARG5 = "-d" ] || [ $ARG5 = "--disable-autoopen" ]; then
    disableAutoopen="y"
else
    disableAutoopen="n"
fi

if ! type "grep" > /dev/null; then
    echo "ERROR: grep is not installed."
    exit 1
fi
if ! type "curl" > /dev/null; then
    echo "ERROR: curl is not installed."
    exit 1
fi
if ! type "wget" > /dev/null; then
    echo "ERROR: wget is not installed."
    exit 1
fi
if ! type "unzip" > /dev/null; then
    echo "ERROR: unzip is not installed."
    exit 1
fi
if ! type "7z" > /dev/null; then
    echo "7zip is not installed, but is only necessary if you have a .7z mod."
fi
if ! type "unrar" > /dev/null; then
    echo "unrar is not installed, but is only necessary if you have a .rar mod."
fi

if [ $ignorePrompt = "n" ]; then
    echo ""
    echo ""
    echo ""
    echo "You must have run Subnautica and processed Vulkan shaders at least once before using this program."
    read -p "Press ENTER to confirm you've done it at any point, or quit the program if you have not."
fi

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
                echo "Could not find Subnautica directory. Check if installed, or pass location as argument."
                echo "(Usually at:)"
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

if [ -d "$subnauticaDirectory/BepInEx" ]; then
    if [ -d "$subnauticaDirectory/BepInEx/plugins" ]; then
        if [ "$(find "$subnauticaDirectory/BepInEx/plugins" -maxdepth 1 -printf 1 | wc -m)" -eq 2 ]; then
            if [ -d "$subnauticaDirectory/BepInEx/plugins/Tobey" ]; then
                rm -rf "$subnauticaDirectory/BepInEx"
            else
                echo ""
                echo ""
                echo ""
                echo "$subnauticaDirectory/BepInEx already exists. Please back up $subnauticaDirectory/BepInEx/config and $subnauticaDirectory/BepInEx/plugins, then delete."
                exit 1
            fi
        elif  find "$subnauticaDirectory/BepInEx/plugins" -maxdepth 0 -empty | read v; then
            rm -rf "$subnauticaDirectory/BepInEx"
        else
            echo ""
            echo ""
            echo ""
            echo "$subnauticaDirectory/BepInEx already exists. Please back up $subnauticaDirectory/BepInEx/config and $subnauticaDirectory/BepInEx/plugins, then delete."
            exit 1
        fi
    else
        rm -rf "$subnauticaDirectory/BepInEx"
    fi
fi

if [ $ignorePrompt = "n" ]; then
    echo ""
    echo ""
    echo ""
    echo "Make sure you've set your Subnautica launch options as:"
    echo 'WINEDLLOVERRIDES="winhttp=n,b" %command%'
    echo "You can find this setting by going to Subnautica in your Steam Library, clicking the gear icon, and then clicking 'Properties'."
    read -p "(Press enter to confirm you've set your game launch options. Do NOT open Subnautica.)"
fi

echo "Installing BepInEx..."
cd $subnauticaDirectory
wget https://github.com/toebeann/BepInEx.Subnautica/releases/latest/download/Tobey.s.BepInEx.Pack.for.Subnautica.zip
y | unzip Tobey.s.BepInEx.Pack.for.Subnautica.zip
rm -f Tobey.s.BepInEx.Pack.for.Subnautica.zip
cd $HOME
if [ $tweaks = "y" ]; then
    wget https://github.com/toebeann/BepInExTweaks.Subnautica/releases/latest/download/Tobey.BepInExTweaks.Subnautica.zip
    unzip Tobey.BepInExTweaks.Subnautica.zip
    mv BepInEx/plugins/Tobey/BepInEx\ Tweaks BepInEx\ Tweaks || mv BepInEx/plugins/BepInEx\ Tweaks BepInEx\ Tweaks
    rm -rf BepInEx
    rm -f Tobey.BepInExTweaks.Subnautica.zip
fi

if [ $disableAutoopen = "n" ]; then
    steam steam://rungameid/264710
    sleep 10
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    read -p "Press ENTER once Subnautica is closed."
elif [ $disableAutoopen = "y" ]; then
    read -p "Please open Subnautica, then quit it from the menu. Then press ENTER."
    if [ $ignorePrompt = "n" ]; then
        read -p "Are you sure you opened Subnautica, then quit from menu? Press ENTER if so."
    fi
fi

echo "Installing Nautilus..."
temp_dir=$(mktemp -d)
cd ${temp_dir}
git clone https://github.com/SubnauticaModding/Nautilus
cd Nautilus
curTag="$(git describe --tags --abbrev=0)"
cd /
rm -rf $temp_dir
suffix=${curTag/-pre/}
cd $subnauticaDirectory/BepInEx/plugins/
wget "https://github.com/SubnauticaModding/Nautilus/releases/download/${curTag}/Nautilus_SN.STABLE_${suffix}.zip"
unzip Nautilus_SN.STABLE_${suffix}.zip
mv plugins/Nautilus Nautilus
rm -f Nautilus_SN.STABLE_${suffix}.zip
rm -rf plugins

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

if [ $tweaks = "y" ]; then
    echo "Installing BepInEx Tweaks..."
    wget https://github.com/toebeann/BepInExTweaks.Subnautica/releases/latest/download/Tobey.BepInExTweaks.Subnautica.zip
    y | unzip Tobey.BepInExTweaks.Subnautica.zip
    mv BepInEx/plugins/Tobey/BepInEx\ Tweaks BepInEx\ Tweaks || mv BepInEx/plugins/BepInEx\ Tweaks BepInEx\ Tweaks
    rm -rf BepInEx
    rm -f Tobey.BepInExTweaks.Subnautica.zip
fi

if [ $terrainPatcher = "y" ]; then
    echo "Installing Terrain Patcher..."
    cd $subnauticaDirectory/BepInEx/plugins/
    curl -s https://api.github.com/repos/Esper89/Subnautica-TerrainPatcher/releases/latest \
    | grep "browser_download_url.*errainPatcher.zip" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -qi -
    unzip TerrainPatcher.zip
    rm -f TerrainPatcher.zip
fi

echo ""
echo ""
echo ""
echo "Done!"
echo "Now download any mods you like from Nexus or Github, and place them in '$subnauticaDirectory/BepInEx/plugins/' (WITHOUT unzipping)."
if [ $changedDirectory = "n" ]; then
    echo "Then run 'unzip-mods-in-bulk.sh', and you're finished!"
else
    echo "Then run 'unzip-mods-in-bulk.sh -n $subnauticaDirectory', and you're finished!"
fi
echo ""
echo ""
echo ""
echo "(You can also place your mods in their own folder if you want to keep copies of them. If you decide to do that, then run:)"
if [ $changedDirectory = "n" ]; then
    echo "unzip-mods-in-bulk.sh <folder/zips/are/stored/in>"
else
    echo "unzip-mods-in-bulk.sh <folder/zips/are/stored/in> $subnauticaDirectory'"
fi
echo ""
echo "If everything installed successfully, 'install.sh' is no longer necessary and can now be deleted."

