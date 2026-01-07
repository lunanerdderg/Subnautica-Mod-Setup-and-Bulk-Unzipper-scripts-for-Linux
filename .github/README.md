#### TL;DR: Copy and paste the [Launch Options](#launch-options-necessary) into Subnautica's properties, run the [install command](#install), run `install.sh`, close Subnautica when it automatically opens, download your desired mods and dependencies into `~/.local/share/Steam/steamapps/common/Subnautica/BepInEx/plugins/`, then run `unzip-mods-in-bulk.sh`.

These scripts are intended for Linux, and only work on Linux.

These scripts are also intended for Steam. Other launcher users should look at the [Epic users](#epic-users) section.

* [`install.sh`](https://github.com/lunanerdderg/Subnautica-Mod-Setup-and-Bulk-Unzipper-scripts-for-Linux/blob/main/install.sh) semi-automates and eases the process of installing BepInEx and Nautilus.

* [`unzip-mods-in-bulk.sh`](https://github.com/lunanerdderg/Subnautica-Mod-Setup-and-Bulk-Unzipper-scripts-for-Linux/blob/main/unzip-mods-in-bulk.sh) installs already-downloaded mods (which you can get from [Nexus](https://www.nexusmods.com/games/subnautica), [Github](https://github.com/topics/subnautica), or [Discord](https://discord.gg/UpWuWwq)) in bulk, so you don't have to extract every one of them yourself. It handles .zip, .7z, .rar, and .tar archives as well as their subfolders.
  * (The organization of subfolders is different between mods, since mod developers are a community of people. The script should be able to handle most inconsistencies.)
  * `unzip-mods-in-bulk.sh` can be re-used as much as you like to install more mods.

# IMPORTANT (before you begin):

## Launch Options: (NECESSARY)

Add the following to your Subnautica launch options before running `install.sh`:

```
WINEDLLOVERRIDES="winhttp=n,b" %command%
```

*Mods do not work unless these launch options are added!*

### How to change Launch Options:

(Unfortunately, I don't know any way to automate this process through scripting.)

1. Go to your Steam Library and navigate to Subnautica.
2. Right click on Subnautica in the sidebar, or click the gear icon.

   <img src="https://raw.githubusercontent.com/lunanerdderg/Subnautica-Mod-Setup-and-Bulk-Unzipper-scripts-for-Linux/master/.github/properties-screenshot.jpg" alt="Properties screenshot" width="400"/>

3. Click "Properties"
4. Paste the aforementioned into the "Launch Options" section at the bottom

   <img src="https://raw.githubusercontent.com/lunanerdderg/Subnautica-Mod-Setup-and-Bulk-Unzipper-scripts-for-Linux/master/.github/launch_options-screenshot.jpg" alt="Launch Options screenshot" width="400"/>

## Dependencies (can be skipped):

**The script will tell you what you have don't have installed. This section can be skipped.**

(Dependencies with no link should be installed through your distribution's package manager. **Do not try to install these without checking if you already have them first.**)

* **[Steam](https://store.steampowered.com/about/download)**
* **grep** (Pre-installed on most distros)
* **curl** (Pre-installed on most distros)
* **wget** (Pre-installed on most distros)
* **unzip** (Pre-installed on most distros)
* Optional, unless .7z or .rar used by mod:
  * Either **p7zip-full** or **[7zip](https://7-zip.org/download.html)** (for mods compressed in .7z format)
  * Either **unrar-free** or **[unrar](https://www.rarlab.com/rar_add.htm)** (for mods compressed in .rar format)

## Install:

### With a single command (recommended):

Use [`cd`](https://www.geeksforgeeks.org/linux-unix/cd-command-in-linux-with-examples/) to get to whatever directory you want to install into, then copy and paste this into your terminal:

```
curl -s https://api.github.com/repos/lunanerdderg/Subnautica-Mod-Setup-and-Bulk-Unzipper-scripts-for-Linux/releases/latest \
| grep "browser_download_url.*Linux.tar" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -
tar -xf Subnautica-Mod-Setup-and-Bulk-Unzipper-scripts-for-Linux.tar
rm -f Subnautica-Mod-Setup-and-Bulk-Unzipper-scripts-for-Linux.tar
chmod +x install.sh
chmod +x unzip-mods-in-bulk.sh
```

### Releases:

As an alternative to the command, you can download your preferred release [here](https://github.com/lunanerdderg/Subnautica-Mod-Setup-and-Bulk-Unzipper-scripts-for-Linux/releases), decompress it, and run `chmod +x` on both shell scripts.

# Directions:

Don't worry about memorizing any instructions. `install.sh` will remind you.

1. Make sure you've run Subnautica at least once before using these scripts.
2. Copy and paste the [Launch Options](#launch-options-necessary) into Subnautica's properties.
3. [Install the scripts.](#install)
4. Run `install.sh` in the terminal (ideally the same terminal as before) with the desired [parameters](#parameters) listed below. Follow any instructions it gives you.
5. When it automatically opens Subnautica for you, quit from Subnautica's main menu. (Fully exiting Steam is no longer necessary as of [v0.1.2](https://github.com/lunanerdderg/Subnautica-Mod-Setup-and-Bulk-Unzipper-scripts-for-Linux/releases/tag/v0.1.2).)
    * `install.sh` can now be deleted, if you want.
6. *Keep the terminal window open.* Download all the mods you want to install. (Make sure to keep track of dependencies! On Nexus in a mod's "Description" tab, clicking the "Requirements" button will reveal them.)
7. Place all the mods in a single folder if you want to keep the .zips, or place them in `~/.local/share/Steam/steamapps/common/Subnautica/BepInEx/plugins/` if you do not.
8. Run `unzip-mods-in-bulk.sh` in the terminal (again, ideally the same terminal as before) with the location of your mod folder as an argument, or leave blank if you placed your mods in `~/.local/share/Steam/steamapps/common/Subnautica/BepInEx/plugins/`.

That's it!

## Parameters:

### install.sh:

Every listed parameter is optional, and may be used in any order.

    -h, --help               Display this guide
    path/to/directory        Use path as Subnautica game directory instead of Steam's default
    -n, --no-tweaks          Do not install Toebeann's BepInEx Tweaks for Subnautica
    -t, --terrain-patcher    Install Esper89's Terrain Patcher mod
    -d, --disable-autoopen   Do not open Subnautica automatically. Allow user to do it manually 
	                         instead. Exiting from Steam fully is NOT NECESSARY with this option.
    -i, --ignore-prompt      Disable most user prompts (do NOT use if first time running)
*Note: It's impossible to fully automate this script. Eventually the user will encounter at least one prompt.*

### unzip-mods-in-bulk.sh:

All listed parameters are optional, but MUST be used IN ORDER. If you want to use the second but not the first, pass `-n` or `--None` as the first parameter.

Example: `unzip-mods-in-bulk.sh -n directory/of/Subnautica`

	-h, --help: Show this help menu
	1. Folder containing mod zips (defaults to "Subnautica/BepInEx/plugins" folder)
	2. Directory of Subnautica game folder

*Note: Unlike `install.sh`, this script has no user prompts.*

## Epic users:

I do not own any Epic games, nor have I ever used the Epic Games Store, so I truly have no idea if this will work on Heroic or Lutris. You might have some success if you follow the normal [installation](#install) and [use](#directions) instructions, but run `install.sh` like this:

```
install.sh -d <location of Subnautica folder>
```

Then open and close Subnautica when it prompts you. Also run `unzip-mods-in-bulk.sh` like this:

```
install.sh <location of mods> <location of Subnautica folder>
```

# License

You may view the Mozilla Public License 2.0 [here](https://raw.githubusercontent.com/lunanerdderg/Subnautica-Mod-Setup-and-Bulk-Unzipper-scripts-for-Linux/master/.github/LICENSE.txt), but the TL;DR is that you can use this project for whatever you like, as long as:

* You credit me
* Your project is open-source
