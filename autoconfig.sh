#!/bin/bash
CONFIG_DIR="~/.config"

if [ $(logname) == "root" ]; then
    echo "User logged in as root, It is unsafe to run the program in root"
    exit
fi
if [ $USER != "root" ]; then
    echo "Program must be run with sudo"
    exit
fi
username=$(logname)

pre-requisites() {
    pacman -Syy --noconfirm --needed git openssh
}

AUR() {
    sudo -u $username git clone https://aur.archlinux.org/yay-bin.git /tmp/yay
    cd /tmp/yay; sudo -u $username makepkg -sci --noconfirm; cd -
}

Packages() {
    cat ./packages.txt | while read -r line; do
        sudo -u $username echo "Installing $line"
        sudo -u $username yay -S --needed --noconfirm $line 
        echo "$line Installed"
    done
}

Environment() {
    pacman -S sway swaybg swayidle swaylock waybar sddm ranger --noconfirm
}

Browser() {
    pacman -S --needed firefox-developer-edition --noconfirm
    sudo -u $username timeout 10s firefox-developer-edition --headless --first-startup
    killall "firefox" "firefox-bin" "firefox-developer-edition" || true

    HomeDIR="~/.mozilla/firefox"
    release=$(sed -n "2p" ${HomeDIR}/installs.ini)
    release=$(echo $release | sed 's/^Default=//')
    cd "${HomeDIR}/${release}"; git clone https://github.com/MichaelPetersen22/asimov-firefox-css .; cd -
}

Shell() {
    pacman -S --noconfirm fish
    chsh -S /bin/fish
}

Terminal() {
    pacman -S --noconfirm tilix
}

Config() {
    systemctl enable sddm, firewalld
    sudo -u $username git clone https://github.com/MichaelPetersen22/dotfiles ~/.config/dotfiles
    mv -rf ~/.config/dotfiles/* ~/.config/
}

Styles() {
    sudo -u $username git clone https://github.com/vinceliuice/Fluent-gtk-theme /tmp/fluent
    sudo -u $username git clone https://github.com/vinceliuice/Tela-icon-theme /tmp/tela
    cd /tmp/fluent; ./install.sh -c dark -n Fluent-Dark; cd -
    cd /tmp/tela; ./install.sh -c standard; cd -
}

GRUB() {
    pacman -S os-prober --noconfirm
    mount /dev/nvme0n1p1 /mnt
    sudo -u $username git clone https://github.com/vinceliuice/grub2-themes /tmp/grub
    cd /tmp/grub; ./install.sh -t tela -i color -s 4k; cd -
}

pre-requisites
AUR
Packages
Environment
Browser
Terminal
Config
Styles
GRUB
Shell