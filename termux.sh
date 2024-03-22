#!/bin/bash

# Colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
rest='\033[0m'

# Check Dependencies build
check_dependencies_build() {
    local dependencies=("curl" "wget" "git" "golang")

    for dep in "${dependencies[@]}"; do
        if ! dpkg -s "${dep}" &> /dev/null; then
            echo -e "${yellow}${dep} is not installed. Installing...${rest}"
            pkg install "${dep}" -y
        fi
    done
}

# Check Dependencies
check_dependencies() {
    local dependencies=("curl" "openssl-tool" "wget" "unzip")

    for dep in "${dependencies[@]}"; do
        if ! dpkg -s "${dep}" &> /dev/null; then
            echo -e "${yellow}${dep} is not installed. Installing...${rest}"
            pkg install "${dep}" -y
        fi
    done
}

# Install
install() {
    if command -v warp &> /dev/null || command -v usef &> /dev/null; then
        echo -e "${green}Warp is already installed.${rest}"
        return
    fi

    echo -e "${green}Installing Warp...${rest}"
    pkg update -y && pkg upgrade -y
    pacman -Syu openssh = apt update; apt full-upgrade -y; apt install -y openssh
    check_dependencies

    if wget https://github.com/bepass-org/warp-plus/releases/download/v1.1.0/warp-plus-android-arm64.cdb551.zip &&
        unzip warp-plus-android-arm64.cdb551.zip &&
        mv warp-plus warp &&
        chmod +x warp &&
        cp warp "$PREFIX/bin/usef" &&
        cp warp "$PREFIX/bin/warp-plus" &&
        cp warp "$PREFIX/bin/warp"; then
        rm "README.md" "LICENSE" "warp-plus-android-arm64.cdb551.zip"
        echo "================================================"
        echo -e "${green}Warp installed successfully.${rest}"
        socks
    else
        echo -e "${red}Error installing Warp.${rest}"
    fi
}

# Install arm
install_arm() {
    if command -v warp &> /dev/null || command -v usef &> /dev/null; then
        echo -e "${green}Warp is already installed.${rest}"
        return
    fi

    echo -e "${green}Installing Warp...${rest}"
    pkg update -y && pkg upgrade -y
    pacman -Syu openssh = apt update; apt full-upgrade -y; apt install -y openssh
    check_dependencies

    # Determine architecture
    case "$(dpkg --print-architecture)" in
        i386) ARCH="386" ;;
        amd64) ARCH="amd64" ;;
        armhf) ARCH="arm5" ;;
        arm) ARCH="arm7" ;;
        aarch64) ARCH="arm64" ;;
        *) echo -e "${red}Unsupported architecture.${rest}"; return ;;
    esac

    WARP_URL="https://github.com/bepass-org/warp-plus/releases/download/v1.1.0/warp-plus-linux-$ARCH.cdb551.zip"

    if wget "$WARP_URL" &&
        unzip "warp-plus-linux-$ARCH.cdb551.zip" &&
        mv warp-plus warp &&
        chmod +x warp &&
        cp warp "$PREFIX/bin/usef" &&
        cp warp "$PREFIX/bin/warp-plus" &&
        cp warp "$PREFIX/bin/warp"; then
        rm "README.md" "LICENSE" "warp-plus-linux-$ARCH.cdb551.zip"
        echo "================================================"
        echo "================================================"
        echo -e "${green}Warp installed successfully.${rest}"
        socks
    else
        echo -e "${red}Error installing Warp.${rest}"
    fi
}

# Get socks config
socks() {
   echo ""
   echo -e "${yellow}Copy this Config to ${purple}V2ray${green} Or ${purple}Nekobox ${yellow}and Exclude Termux${rest}"
   echo "================================================"
   echo -e "${green}socks://Og==@127.0.0.1:8086#warp_(usef)${rest}"
   echo "or"
   echo -e "${green}Manually create a SOCKS configuration with IP ${purple}127.0.0.1 ${green}and port${purple} 8086..${rest}"
   echo "================================================"
   echo -e "${yellow}To run again, type:${green} warp ${rest}or${green} usef ${rest}or${green} ./warp${rest}"
   echo "================================================"
   echo -e "${green} If you get a 'Bad address' error, run ${yellow}[Arm]${rest}"
   echo "================================================"
   echo "================================================"
   echo ""
}

# Gool (warp in warp)
gool() {
    echo -e "${purple}*********************************${rest}"
    echo -e "${green}This option changes your current location to the nearest and best location.${rest}"
    echo -e "${purple}*********************************${rest}"
    warp --gool
}

# Psiphon
psiphon_location() {
    echo -e "${purple}*********************************${rest}"
    echo -e "${cyan}Please choose a location from the list below by entering its number:${rest}"
    echo -e "${purple}1)${rest} Austria (AT)"
    echo -e "${purple}2)${rest} Belgium (BE)"
    echo -e "${purple}3)${rest} Bulgaria (BG)"
    echo -e "${purple}4)${rest} Brazil (BR)"
    echo -e "${purple}5)${rest} Canada (CA)"
    echo -e "${purple}6)${rest} Switzerland (CH)"
    echo -e "${purple}7)${rest} Czech Republic (CZ)"
    echo -e "${purple}8)${rest} Germany (DE)"
    echo -e "${purple}9)${rest} Denmark (DK)"
    echo -e "${purple}10)${rest} Estonia (EE)"
    echo -e "${purple}11)${rest} Spain (ES)"
    echo -e "${purple}12)${rest} Finland (FI)"
    echo -e "${purple}13)${rest} France (FR)"
    echo -e "${purple}14)${rest} United Kingdom (GB)"
    echo -e "${purple}15)${rest} Hungary (HU)"
    echo -e "${purple}16)${rest} Ireland (IE)"
    echo -e "${purple}17)${rest} India (IN)"
    echo -e "${purple}18)${rest} Italy (IT)"
    echo -e "${purple}19)${rest} Japan (JP)"
    echo -e "${purple}20)${rest} Latvia (LV)"
    echo -e "${purple}21)${rest} Netherlands (NL)"
    echo -e "${purple}22)${rest} Norway (NO)"
    echo -e "${purple}23)${rest} Poland (PL)"
    echo -e "${purple}24)${rest} Romania (RO)"
    echo -e "${purple}25)${rest} Serbia (RS)"
    echo -e "${purple}26)${rest} Sweden (SE)"
    echo -e "${purple}27)${rest} Singapore (SG)"
    echo -e "${purple}28)${rest} Slovakia (SK)"
    echo -e "${purple}29)${rest} Ukraine (UA)"
    echo -e "${purple}30)${rest} United States (US)"

    echo -en "${green}Enter the ${purple}number${green} of the location [${yellow}default: 1${green}]: ${rest}"
    choice=${choice:-AT}
    read -r choice
    
    case "$choice" in
        1) location="AT" ;;
        2) location="BE" ;;
        3) location="BG" ;;
        4) location="BR" ;;
        5) location="CA" ;;
        6) location="CH" ;;
        7) location="CZ" ;;
        8) location="DE" ;;
        9) location="DK" ;;
        10) location="EE" ;;
        11) location="ES" ;;
        12) location="FI" ;;
        13) location="FR" ;;
        14) location="GB" ;;
        15) location="HU" ;;
        16) location="IE" ;;
        17) location="IN" ;;
        18) location="IT" ;;
        19) location="JP" ;;
        20) location="LV" ;;
        21) location="NL" ;;
        22) location="NO" ;;
        23) location="PL" ;;
        24) location="RO" ;;
        25) location="RS" ;;
        26) location="SE" ;;
        27) location="SG" ;;
        28) location="SK" ;;
        29) location="UA" ;;
        30) location="US" ;;
        *) echo "Invalid choice. Please select a valid location number." ;;
    esac

    # Now use the selected location variable $location in your script
    echo "Selected location: $location"
    warp --cfon --country $location
}

#Uninstall
uninstall() {
    warp="$PREFIX/bin/warp"
    directory="/data/data/com.termux/files/home/warp-plus"
    home="/data/data/com.termux/files/home"
    if [ ! -f "$warp" ]; then
        rm -rf "$directory" "$PREFIX/bin/usef" "wa.py" "$PREFIX/bin/warp" "$PREFIX/bin/warp-plus" "warp" "stuff" > /dev/null 2>&1
        echo -e "${purple}*********************************${rest}"
        echo -e "${red}Uninstallation completed.${rest}"
        echo -e "${purple}*********************************${rest}"
    else
        echo -e "${yellow} ____________________________________${rest}"
        echo -e "${red} Not installed.Please Install First.${rest}${yellow}|"
        echo -e "${yellow} ____________________________________${rest}"
    fi
}

# Warp to Warp plus
warp_plus() {
    if ! command -v python &> /dev/null; then
        echo "Installing Python..."
        pkg install python -y
    fi

    echo -e "${green}Downloading and running${purple} Warp+ script...${rest}"
    wget -O wa.py https://raw.githubusercontent.com/Ptechgithub/configs/main/wa.py
    python wa.py
}

# Menu
menu() {
    clear
    echo -e "${green}By --> Peyman * Github.com/Ptechgithub * ${rest}"
    echo ""
    echo -e "${yellow}❤️Github.com/${cyan}bepass-org${yellow}/warp-plus❤️${rest}"
    echo -e "${purple}*********************************${rest}"
    echo -e "${blue}  ###${cyan} Warp-Plus in Termux ${blue}###${rest} ${purple}  * ${rest}"
    echo -e "${purple}*********************************${rest}"
    echo -e "${cyan}1]${rest} ${green}Install Warp (vpn)${purple}           * ${rest}"
    echo -e "                              ${purple}  * ${rest}"
    echo -e "${cyan}2]${rest} ${green}Install Warp (vpn) [${yellow}Arm${green}] ${purple}    * ${rest}"
    echo -e "                              ${purple}  * ${rest}"
    echo -e "${cyan}3]${rest} ${green}Uninstall${rest}${purple}                    * ${rest}"
    echo -e "                              ${purple}  * ${rest}"
    echo -e "${cyan}4]${rest} ${green}Gool [${yellow}warp in warp${green}]${purple}          * ${rest}"
    echo -e "                              ${purple}  * ${rest}"
    echo -e "${cyan}5]${rest} ${green}Pshiphon [${yellow}+ All Locations${green}]${purple}   * ${rest}"
    echo -e "                              ${purple}  * ${rest}"
    echo -e "${cyan}6]${rest} ${green}Warp to ${purple}Warp plus${green} [${yellow}Free GB${green}]${rest}${purple}  * ${rest}"
    echo -e "                              ${purple}  * ${rest}"
    echo -e "${red}0]${rest} ${green}Exit                         ${purple}* ${rest}"
    echo -e "${purple}*********************************${rest}"
}

# Main
menu
echo -en "${cyan}Please enter your selection [${yellow}0-6${green}]:${rest}"
read -r choice

case "$choice" in
   1)
        install
        warp
        ;;
    2)
        install_arm
        warp
        ;;
    3)
        uninstall
        ;;
    4)
        gool
        ;;
    5)
        psiphon_location
        ;;
    6)
        warp_plus
        ;;
    0)
        echo -e "${cyan}Exiting...${rest}"
        exit
        ;;
    *)
        echo "Invalid choice. Please select a valid option."
        ;;
esac