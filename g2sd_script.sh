#!/usr/bin/env bash
set -euo pipefail
APP_ID=39510
# STEAM_PATH="$HOME/.local/share/Steam/"
STEAM_PATH=$(find_steam)
GOTHIC2_PATH="${STEAM_PATH}steamapps/common/Gothic II/"
GOTHIC_INI_PATH="${GOTHIC2_PATH}system/Gothic.ini"
SYSTEMPACK_INI_PATH="${GOTHIC2_PATH}system/SystemPack.ini"
PREFIX_PATH="${STEAM_PATH}steamapps/compatdata/$APP_ID/pfx/"
WORKSHOP_DIR="${STEAM_PATH}steamapps/workshop/content/$APP_ID/"
LHIVER_ID=2973766210
XP_BAR_ID=2787139182
ADV_INVENTORY_ID=2787311989
# Function to check if Gothic.ini exists
check_gothic_ini() {
    if [[ -f "$GOTHIC_INI_PATH" ]]; then
        return 0  # exists
    else
        echo "ERROR: Gothic.ini file not found at $GOTHIC_INI_PATH."
        return 1  # does not exist
    fi
}
# Function to find where Steam is installed
find_steam() {
    # Flatpak
    if [[ -d "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/" ]]; then
        echo "Steam found at: $HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/"
        return
    fi

    # Native package
    if [[ -d "$HOME/.local/share/Steam/" ]]; then
        echo "Steam found at: $HOME/.local/share/Steam/"
        return
    fi
    if [[ -d "$HOME/.steam/steam/"]]; then
        echo "Steam found at: $HOME/.steam/steam/"
        return
    fi

    echo "ERROR: Could not find Steam installation path." >&2
    exit 1
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
# Fix Gothic 2 background music bug
flatpak run com.github.Matoking.protontricks 39510 directmusic
USER_REG_PATH="${PREFIX_PATH}user.reg"
if [[ -f "$USER_REG_PATH" ]]; then
    sed -i 's/"\*dsound"="native"/"ddraw"="native,builtin"/' "$USER_REG_PATH"
else
    echo "ERROR: user.reg file not found at $USER_REG_PATH." >&2
fi
if grep -q '"ddraw"="native,builtin"' "$USER_REG_PATH"; then
    echo "user.reg modified successfully.\n"
else
    echo "ERROR: Failed to modify user.reg." >&2
fi
# Adjust interface scale
echo "Adjusting interface scale..."
if [[ -f "$SYSTEMPACK_INI_PATH" ]]; then
    sed -i '/^Scale=/c\Scale=1.4' "$SYSTEMPACK_INI_PATH"
else
    echo "ERROR: SystemPack.ini file not found at $SYSTEMPACK_INI_PATH." >&2
fi
if grep -q 'Scale=1.4' "$SYSTEMPACK_INI_PATH"; then
    echo "SystemPack.ini - Scale modified successfully."
else
    echo "ERROR: Failed to modify SystemPack.ini." >&2
fi
# Fix L'Hiver interface scale
echo -e "\nAdjusting L'Hiver interface scale..."
LHIVER_DIR="$WORKSHOP_DIR$LHIVER_ID/"
if [[ -d "$LHIVER_DIR" ]]; then
    for FILE in Lhiver_masty_de.ini Lhiver_masty_en.ini Lhiver_masty_pl.ini; do
        LHIVER_INI_PATH="${LHIVER_DIR}system/$FILE"
        if [[ -f "$LHIVER_INI_PATH" ]]; then
            sed -i '/INTERFACE.Scale=0/d' "$LHIVER_INI_PATH"
        else
            echo "ERROR: File $FILE not found at $LHIVER_INI_PATH." >&2
        fi
        if ! grep -q 'INTERFACE.Scale=0' "$LHIVER_INI_PATH"; then
            echo "$FILE - Scale modified successfully."
        else
            echo "ERROR: Failed to modify $FILE." >&2
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
        sed -i '/^needTextInCenter=/c\needTextInCenter=0' "$GOTHIC_INI_PATH"
        sed -i '/^possibleFontsMultiplierIdx=/c\possibleFontsMultiplierIdx=5' "$GOTHIC_INI_PATH"
    else
        echo "ERROR: Gothic.ini file not found at $GOTHIC2_PATH/system." >&2
    fi
    if grep -q 'needTextInCenter=0' "$GOTHIC_INI_PATH" && grep -q 'possibleFontsMultiplierIdx=5' "$GOTHIC_INI_PATH"; then
        echo "Gothic.ini - XP Bar modified successfully."
    else
        echo "ERROR: Failed to modify Gothic.ini." >&2
    fi
else
    echo "XP Bar not installed. Skipping."
fi
# Adjust Union Advanced Inventory
echo -e "\nAdjusting Union Advanced Inventory..."
ADV_INVENTORY_PATH="$WORKSHOP_DIR$ADV_INVENTORY_ID/"
if [[ -d "$ADV_INVENTORY_PATH" ]]; then
        if check_gothic_ini; then
            sed -i '/^invAdvCntRows=/c\invAdvCntRows=4' "$GOTHIC_INI_PATH"
            sed -i '/^invAdvCntCol=/c\invAdvCntCol=6' "$GOTHIC_INI_PATH"
            sed -i '/^invSizeCell=/c\invSizeCell=600' "$GOTHIC_INI_PATH"
            sed -i '/^customTransparencyItemsIdx=/c\customTransparencyItemsIdx=4' "$GOTHIC_INI_PATH"
        else
            echo "ERROR: Gothic.ini file not found at $GOTHIC2_PATH/system." >&2
        fi
        if grep -q "invAdvCntRows=4" "$GOTHIC_INI_PATH" && \
           grep -q "invAdvCntCol=6" "$GOTHIC_INI_PATH" && \
           grep -q "invSizeCell=600" "$GOTHIC_INI_PATH" && \
           grep -q "customTransparencyItemsIdx=4" "$GOTHIC_INI_PATH"; then
            echo "Gothic.ini - Union Advanced Inventory modified successfully."
        else
            echo "ERROR: Failed to modify Gothic.ini." >&2
        fi
else
    echo "Union Advanced Inventory not installed. Skipping."
fi
# Finished
echo -e "\nAll done. Gothic 2 is now set up and configured for the Steam Deck."
echo "Exiting in 3 seconds..."
sleep 3
