#!/bin/sh

set -eu

dependencies() {
  if [ "${DISTRO:?}" = "Gentoo" ] || [ "${DISTRO:?}" = "gentoo" ]
  then
    sudo emerge --ask dev-vcs/git media-libs/fontconfig x11-base/xorg-proto x11-libs/libX11 x11-libs/libXft x11-libs/libXinerama x11-terms/alacritty media-fonts/jetbrains-mono media-fonts/fontawesome media-gfx/feh x11-apps/xsetroot x11-apps/setxkbmap media-fonts/takao-fonts media-sound/pnmixer  gnome-extra/nm-applet sys-devel/gcc app-text/asciidoc dev-lang/python dev-libs/libconfig dev-libs/libev dev-libs/libpcre dev-libs/uthash dev-python/xcffib  dev-util/meson dev-util/meson-format-array dev-util/ninja sys-apps/dbus virtual/opengl virtual/pkgconfig x11-apps/xhost x11-base/xorg-server x11-libs/libXext x11-libs/libdrm x11-libs/libxcb x11-libs/pixman x11-libs/xcb-util-image x11-libs/xcb-util-renderutil x11-misc/dunst xfce-base/thunar xfce-extra/xarchiver xfce-extra/thunar-archive-plugin x11-misc/rofi x11-misc/stalonetray app-admin/doas x11-misc/cbatticon app-shells/dash lxde-base/lxappearance x11-misc/sddm net-p2p/qbittorrent > /dev/null
  elif [ "${DISTRO:?}" = "Arch" ] || [ "${DISTRO:?}" = "arch" ]
  then
    sudo pacman -S git fontconfig xorgproto libx11 libxft libxinerama alacritty ttf-jetbrains-mono ttf-font-awesome feh xorg-xsetroot xorg-setxkbmap network-manager-applet dunst thunar xarchiver thunar-archive-plugin rofi doas cbatticon dash lxappearance sddm qbittorrent > /dev/null
    yay -S otf-takao volctl stalonetray pnmixer > /dev/null
  else
    sudo add-apt-repository ppa:aslatter/ppa > /dev/null
    sudo add-apt-repository ppa:qbittorrent-team/qbittorrent-stable > /dev/null
    sudo apt install git build-essential dunst thunar rofi nm-tray fonts-takao libxcb-render-util0-dev libxcb-image0-dev libpixman-1-dev libxcb-util-dev libxcb-damage0-dev libxcb-randr0-dev libxcb-sync-dev libxcb-composite0-dev libxcb-xinerama0-dev libxcb-present-dev libxcb-glx0-dev libegl1-mesa-dev libdbus-glib-1-dev libdrm-dev libxext-dev x11-xserver-utils pkg-config libgl-dev dbus ninja-build meson python3-xcffib uthash-dev libpcre3 libpcre3-dev libev-dev libconfig-dev asciidoc python3 gcc pnmixer feh fonts-font-awesome libxinerama-dev libxft-dev libx11-dev fontconfig xorg xserver-xorg x11proto-dev wget libx11-xcb-dev xarchiver thunar-archive-plugin stalonetray doas cbatticon lxappearance sddm alacritty qbittorrent> /dev/null
    wget https://download.jetbrains.com/fonts/JetBrainsMono-2.242.zip
    unzip JetBrainsMono-2.242.zip
    cd fonts
    sudo mv ttf /usr/share/fonts/jetbrains-mono
    sudo fc-cache -f -v
    cd ..
  fi
}

picom_setup() {
  if [ "${PICOM:?}" = "Jonaburg" ] || [ "${PICOM:?}" = "jonaburg" ]
  then
    if [ "${DISTRO:?}" = "Gentoo" ] || [ "${DISTRO:?}" = "gentoo" ] || [ "${DISTRO:?}" = "Ubuntu" ] || [ "${DISTRO:?}" = "ubuntu" ]
    then
      cd ..
      git clone https://github.com/jonaburg/picom.git
      cd picom
      meson --buildtype=release . build
      ninja -C build
      sudo ninja -C build install
      cd ../DWM
    else
      yay -S picom-jonaburg-git
    fi
    mkdir -p ~/.config/picom
    cp dotfiles/picom/picom-jonaburg.conf ~/.config/picom/picom.conf
  elif [ "${PICOM:?}" = "Ft-labs" ] || [ "${PICOM:?}" = "ft-labs" ]
  then
    if [ "${DISTRO:?}" = "Gentoo" ] || [ "${DISTRO:?}" = "gentoo" ] || [ "${DISTRO:?}" = "Ubuntu" ] || [ "${DISTRO:?}" = "ubuntu" ]
    then
      cd ..
      git clone https://github.com/FT-Labs/picom.git
      cd picom
      git submodule update --init --recursive
      meson --buildtype=release . build
      ninja -C build
      sudo ninja -C build install
      cd ../DWM
    else
      yay -S picom-ftlabs-git
    fi
    mkdir -p ~/.config/picom
    cp dotfiles/picom/picom-labs.conf ~/.config/picom/picom.conf
  else
    echo "Las únicas opciones válidas son Jonaburg/jonaburg, o Ft-labs/ft-labs"
    exit 1
  fi
}

launcher_setup() {
  cd ..
  git clone --depth=1 https://github.com/adi1090x/rofi.git
  cd rofi
  chmod +x setup.sh
  ./setup.sh
  cd ../DWM
  sudo cp dotfiles/launcher/launcher.sh /usr/local/bin
  sudo chmod +x /usr/local/bin/launcher.sh
}

config_files_setup() {
  ##Configuring dunst
  mkdir -p ~/.config/dunst
  cd dotfiles/dunst
  cp -- * ~/.config/dunst
  ##Configuring powermenu
  cd ../powermenu
  mkdir -p ~/.config/rofi
  cp powermenu.rasi ~/.config/rofi
  sudo cp powermenu.sh /usr/local/bin
  sudo chmod +x /usr/local/bin/powermenu.sh
  ##Configuring stalonetray
  cd ../stalonetray
  cp stalonetrayrc ~/.config
  ##Configuring qbittorrent
  cd ../qbittorrent
  mkdir -p ~/.config/qbittorrent
  cp macchiato.qbtheme ~/.config/qbittorrent
  ##Configuring sddm
  cd ../sddm
  sudo cp sddm.conf /etc/sddm.conf.d
  sudo cp faces/root.face.icon /usr/share/sddm/faces/"${USER:?}".face.icon
  cd ../..
  ##Configuring dash as default shell for /bin/sh
  sudo ln -sfT dash /bin/sh
  ##Configuring doas to allow restart or poweroff without sudo
  echo "permit ${USER:?} as root" | sudo tee /etc/doas.conf > /dev/null
  echo "permit nopass ${USER:?} as root cmd /usr/sbin/reboot" | sudo tee -a /etc/doas.conf > /dev/null
  echo "permit nopass ${USER:?} as root cmd /usr/sbin/shutdown" | sudo tee -a /etc/doas.conf > /dev/null
}

terminal_setup() {
  ##Installing fish shell
  if [ "${DISTRO:?}" = "Gentoo" ] || [ "${DISTRO:?}" = "gentoo" ]
  then
    sudo emerge --ask app-shells/fish
  elif [ "${DISTRO:?}" = "Arch" ] || [ "${DISTRO:?}" = "arch" ]
  then
    sudo pacman -S fish
  else
    sudo apt install fish
  fi
  ##Installing starship prompt
  curl -sS https://starship.rs/install.sh | sh
  ##Installing fm6000
  sh -c "$(curl https://codeberg.org/anhsirk0/fetch-master-6000/raw/branch/main/install.sh)"
  ##Adding pixel art for fm6000
  mkdir -p ~/.config/pixelart
  cp dotfiles/pixelart/space_invader.txt ~/.config/pixelart
  ##Adding fish config
  mkdir -p ~/.config/fish
  cp dotfiles/fish/config.fish ~/.config/fish/config.fish
  ##Changing shell for actual user
  chsh -s /bin/fish "${USER:?}"
}

dwm_setup() {
  ##DWM y DMENU
  cd myDwm
  sudo make clean install
  cd ../myDmenu
  sudo make clean install
  cd ..
  ##Instalación de archivos de inicio de DWM
  sudo cp dotfiles/dwminit/dwmstart.sh /usr/local/bin
  sudo cp dotfiles/dwminit/dwm.desktop /usr/share/xsessions
  sudo cp dotfiles/dwminit/statusbar.sh /usr/local/bin
}

valid_distro() {
  valid="false"
  if [ "${DISTRO:?}" = "Gentoo" ] || [ "${DISTRO:?}" = "gentoo" ] || [ "${DISTRO:?}" = "Arch" ] || [ "${DISTRO:?}" = "arch" ] || [ "${DISTRO:?}" = "Ubuntu" ] || [ "${DISTRO:?}" = "ubuntu" ]
  then
    valid="true"
  fi
  echo $valid
}




main() {
  export $(grep -v '^#' .env | xargs)
  valid=$(valid_distro)
  if [ "${valid:?}" = "true" ]
  then
  if [ ${DEPENDENCIES:?} -eq 1 ]
    then
      echo "Installing dependencies..."
      dependencies
      echo "Dependencies successfully installed."
    fi
    if [ ${PICOM_SETUP:?} -eq 1 ]
    then
      echo "Installing picom..."
      picom_setup
      echo "Picom successfully installed."
    fi
    if [ ${LAUNCHER_SETUP:?} -eq 1 ]
    then
      echo "Installing launcher..."
      launcher_setup
      echo "Launcher successfully installed."
    fi
    if [ ${CONFIG_FILES_SETUP:?} -eq 1 ]
    then
      echo "Moving config files..."
      config_files_setup
      echo "Config files successfully moved."
    fi
    if [ ${TERMINAL_SETUP:?} -eq 1 ]
    then
      echo "Customizing terminal..."
      terminal_setup
      echo "Terminal successfully customized."
    fi
    if [ ${DWM_SETUP:?} -eq 1 ]
    then
      echo "Installing Dwm..."
      dwm_setup
      echo "Dwm successfully installed."
    fi
  else
    echo "The only supported values for variable distribution are Gentoo/gentoo, Arch/arch and Ubuntu/ubuntu."
    exit 1
  fi
}

main
