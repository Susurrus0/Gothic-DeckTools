#! /usr/bin/bash
APP_ID=39510
GOTHIC2_PATH="$HOME/.local/share/Steam/steamapps/common/Gothic II/"
GOTHIC_INI_PATH="$HOME/.local/share/Steam/steamapps/common/Gothic II/system/Gothic.ini"
SYSTEM_PACK_PATH="$HOME/.local/share/Steam/steamapps/common/Gothic II/system/SystemPack.ini"
PREFIX_PATH="$HOME/.local/share/Steam/steamapps/compatdata/39510/pfx/"
WORKSHOP_DIR="$HOME/.local/share/Steam/steamapps/workshop/content/39510/"
LHIVER_ID=2973766210
XP_BAR_ID=2787139182
ADV_INVENTORY_ID=2787311989
# Function to check if Gothic.ini exists
check_gothic_ini() {
    if [[ -f "$GOTHIC_INI_PATH" ]]; then
        return 0  # File exists
    else
        echo "ERROR: Gothic.ini file not found at $GOTHIC_INI_PATH."
        return 1  # File does not exist
    fi
}
# Welcome message
echo -e "Welcome to the Gothic 2 Steam Deck script.\n"
echo -e "Before running this script, make sure your Gothic 2 beta is set to 'workshop' in the Steam properties, as well as that you have all the desired mods subscribed in the Steam Workshop."
echo "This script will uninstall Gothic 2 and remove anything from previous installations to ensure a clean install. Are you sure you want to continue? (y/n)"
# Confirmation prompt
read -r answer
if [[ $answer != "y" ]]; then
    echo -e "\nExiting script."
    exit 0
fi
# Uninstall Gothic 2
echo -e "\nUninstalling Gothic 2..."
steam steam://uninstall/$APP_ID
read -p "Press Enter once Gothic 2 has been uninstalled..."
# Remove files from previous installations
echo -e "\nRemoving files from previous Gothic 2 installations..."
rm -rf "$GOTHIC2_PATH"
rm -rf "$PREFIX_PATH"
while [[ -d "$GOTHIC2_PATH" || -d "$PREFIX_PATH" ]]; do
    sleep 2
done
# Install Gothic 2
echo -e "\nInstalling Gothic 2..."
steam steam://install/$APP_ID
read -p "Press Enter once Gothic 2 has been installed..."
# Launch Gothic 2 for the first time
echo -e "\nLaunch Gothic 2 for the first time to generate the necessary configuration files."
echo "The script will open the Launcher. Press 'Play' and close the game after it reaches the main menu."
steam steam://rungameid/39510
read -p "Press Enter once Gothic 2 has been closed..."
# Install Protontricks
echo "Installing Protontricks..."
flatpak install -y com.github.Matoking.protontricks
while ! flatpak list | grep -q "com.github.Matoking.protontricks"; do
    sleep 2
done
# Fix Gothic 2 music bug
flatpak run com.github.Matoking.protontricks 39510 directmusic
USER_REG_PATH="~/.local/share/Steam/steamapps/compatdata/39510/pfx/user.reg"
if [[ -f "$USER_REG_PATH" ]]; then
    sed -i "s/"\*dsound"="native"/"ddraw"="native,builtin"/" "$USER_REG_PATH"
else
    echo "ERROR: user.reg file not found at $USER_REG_PATH."
fi
# Adjust interface scale
echo "Adjusting interface scale..."
if [[ -f "$SYSTEM_PACK_PATH" ]]; then
    sed -i "/^Scale=/c\Scale=1.4/" "$SYSTEM_PACK_PATH"
else
    echo "ERROR: SystemPack.ini file not found at $GOTHIC2_PATH/system."
fi
# Fix L'Hiver interface scale
echo -e "\nAdjusting L'Hiver interface scale..."
LHIVER_DIR="$WORKSHOP_DIR$LHIVER_ID/"
if [[ -d "$LHIVER_DIR" ]]; then
    for FILE in Lhiver_masty_de.ini Lhiver_masty_en.ini Lhiver_masty_pl.ini; do
        LHIVER_INI_PATH="$LHIVER_DIR/system/$FILE"
        if [[ -f "$LHIVER_INI_PATH" ]]; then
            sed -i "/INTERFACE.Scale=0/d" "$LHIVER_INI_PATH"
        else
            echo "ERROR: File $FILE not found in $LHIVER_DIR/system/."
        fi
    done
else
    echo "L'Hiver not installed. Skipping."
fi
# Adjust XP Bar
echo -e "\nAdjusting XP Bar..."
XP_BAR_DIR="$WORKSHOP_DIR$XP_BAR_ID/"
if [[ -d "$XP_BAR_DIR" ]]; then
    if check_gothic_ini; then
        sed -i "/^needTextInCenter=/c\needTextInCenter=0" "$GOTHIC_INI_PATH"
        sed -i "/^possibleFontsMultiplierIdx=/c\possibleFontsMultiplierIdx=5" "$GOTHIC_INI_PATH"
    else
        echo "ERROR: Gothic.ini file not found at $GOTHIC2_PATH/system."
    fi
else
    echo "XP Bar not installed. Skipping."
fi
# Adjust Union Advanced Inventory
echo -e "\nAdjusting Union Advanced Inventory..."
ADV_INVENTORY_PATH="$WORKSHOP_DIR$ADV_INVENTORY_ID/"
if [[ -d "$ADV_INVENTORY_PATH" ]]; then
        if check_gothic_ini; then
            sed -i "/^invAdvCntRows=/c\invAdvCntRows=4" "$GOTHIC_INI_PATH"
            sed -i "/^invAdvCntCol=/c\invAdvCntCol=6" "$GOTHIC_INI_PATH"
            sed -i "/^invSizeCell=/c\invSizeCell=600" "$GOTHIC_INI_PATH"
            sed -i "/^customTransparencyItemsIdx=/c\customTransparencyItemsIdx=4" "$GOTHIC_INI_PATH"
        else
            echo "ERROR: Gothic.ini file not found at $GOTHIC2_PATH/system."
        fi
else
    echo "Union Advanced Inventory not installed. Skipping."
fi
# Finished
echo -e "\nAll done. Gothic 2 is now set up and configured for the Steam Deck."
