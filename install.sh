#!/bin/sh

dependencies() {
  if [ $DISTRO = "Gentoo" ] || [ $DISTRO = "gentoo" ]
  then
  sudo emerge --ask dev-vcs/git media-libs/fontconfig x11-base/xorg-proto x11-libs/libX11 x11-libs/libXft x11-libs/libXinerama x11-terms/alacritty media-fonts/jetbrains-mono media-fonts/fontawesome media-gfx/feh x11-apps/xsetroot x11-apps/setxkbmap media-fonts/takao-fonts media-sound/pnmixer  gnome-extra/nm-applet sys-devel/gcc app-text/asciidoc dev-lang/python dev-libs/libconfig dev-libs/libev dev-libs/libpcre dev-libs/uthash dev-python/xcffib  dev-util/meson dev-util/meson-format-array dev-util/ninja sys-apps/dbus virtual/opengl virtual/pkgconfig x11-apps/xhost x11-base/xorg-server x11-libs/libXext x11-libs/libdrm x11-libs/libxcb x11-libs/pixman x11-libs/xcb-util-image x11-libs/xcb-util-renderutil x11-misc/dunst xfce-base/thunar xfce-extra/xarchiver xfce-extra/thunar-archive-plugin x11-misc/rofi x11-misc/stalonetray app-admin/doas x11-misc/cbatticon app-shells/dash
  elif [ $DISTRO = "Arch" ] || [ $DISTRO = "arch" ]
  then
    sudo pacman -S git fontconfig xorgproto libx11 libxft libxinerama alacritty ttf-jetbrains-mono ttf-font-awesome feh xorg-xsetroot xorg-setxkbmap network-manager-applet dunst thunar xarchiver thunar-archive-plugin rofi doas cbatticon dash
    yay -S otf-takao volctl stalonetray
  elif [ $DISTRO = "Ubuntu" ] || [ $DISTRO = "ubuntu" ]
  then
    sudo apt install git build-essential dunst thunar rofi nm-tray fonts-takao libxcb-render-util0-dev libxcb-image0-dev libpixman-1-dev libxcb-util-dev libxcb-damage0-dev libxcb-randr0-dev libxcb-sync-dev libxcb-composite0-dev libxcb-xinerama0-dev libxcb-present-dev libxcb-glx0-dev libegl1-mesa-dev libdbus-glib-1-dev libdrm-dev libxext-dev x11-xserver-utils pkg-config libgl-dev dbus ninja-build meson python3-xcffib uthash-dev libpcre3 libpcre3-dev libev-dev libconfig-dev asciidoc python3 gcc pnmixer feh fonts-font-awesome libxinerama-dev libxft-dev libx11-dev fontconfig xorg xserver-xorg x11proto-dev wget libx11-xcb-dev xarchiver thunar-archive-plugin stalonetray doas cbatticon
    sudo add-apt-repository ppa:aslatter/ppa
    sudo apt install alacritty
    wget https://download.jetbrains.com/fonts/JetBrainsMono-2.242.zip
    unzip JetBrainsMono-2.242.zip
    cd fonts
    sudo mv ttf /usr/share/fonts/jetbrains-mono
    sudo fc-cache -f -v
    cd ..
  else
    echo "Las únicas opciones válidas son Gentoo/gentoo, Arch/arch o Ubuntu/ubuntu."
    exit 1
  fi
}

picom_setup() {
  if [ $PICOM = "Jonaburg" ] || [ $PICOM = "jonaburg" ]
  then
    if [ $DISTRO = "Gentoo" ] || [ $DISTRO = "gentoo" ] || [ $DISTRO = "Ubuntu" ] || [ $DISTRO = "ubuntu" ]
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
    mkdir -p /home/$USER/.config/picom
    cp dotfiles/picom/picom-jonaburg.conf /home/$USER/.config/picom/picom.conf
  elif [ $PICOM = "Ft-labs" ] || [ $PICOM = "ft-labs" ]
  then
    if [ $DISTRO = "Gentoo" ] || [ $DISTRO = "gentoo" ] || [ $DISTRO = "Ubuntu" ] || [ $DISTRO = "ubuntu" ]
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
    mkdir -p /home/$USER/.config/picom
    cp dotfiles/picom/picom-labs.conf /home/$USER/.config/picom/picom.conf
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
  ##Configurando dunst
  mkdir -p /home/$USER/.config/dunst
  cd dotfiles/dunst
  cp * /home/$USER/.config/dunst
  ##Configurando el powermenu
  cd ../powermenu
  mkdir -p /home/$USER/.config/rofi
  cp powermenu.rasi /home/$USER/.config/rofi
  sudo cp powermenu.sh /usr/local/bin
  sudo chmod +x /usr/local/bin/powermenu.sh
  ##Configurando stalonetray
  cd ../stalonetray
  cp stalonetrayrc /home/$USER/.config
  ##Configurando dash como la shell por defecto para /bin/sh
  sudo ln -sfT dash /bin/sh
  ##Configurando doas para permitir reiniciar y apagar sin poner contraseña
  echo "permit ${USER} as root" | sudo tee /etc/doas.conf > /dev/null
  echo "permit nopass ${USER} as root cmd /usr/sbin/reboot" | sudo tee -a /etc/doas.conf > /dev/null
  echo "permit nopass ${USER} as root cmd /usr/sbin/shutdown" | sudo tee -a /etc/doas.conf > /dev/null
}


dwm_setup() {
  ##DWM y DMENU
  cd ../../myDwm
  sudo make clean install
  cd ../myDmenu
  sudo make clean install
  cd ..
  ##Instalación de archivos de inicio de DWM
  sudo cp dotfiles/dwminit/dwmstart.sh /usr/local/bin
  sudo cp dotfiles/dwminit/dwm.desktop /usr/share/xsessions
  sudo cp dotfiles/dwminit/statusbar.sh /usr/local/bin
}


main() {
  set -eu
  export $(grep -v '^#' .env | xargs)
  if [ $DEPENDENCIES -eq 1 ]
  then
  dependencies
  fi
  if [ $PICOM_SETUP -eq 1 ]
  picom_setup
  fi
  if [ $LAUNCHER_SETUP -eq 1 ]
  then
    launcher_setup
  fi
  if [ $CONFIG_FILES_SETUP -eq 1 ]
  then
  config_files_setup
  fi
  if [ $DWM_SETUP -eq 1 ]
  then
  dwm_setup
  fi
}

main
