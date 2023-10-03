#!/bin/sh

set -eu

dependencies() {
  if [ "${DISTRO:?}" = "Gentoo" ] || [ "${DISTRO:?}" = "gentoo" ]
  then
    sudo emerge --ask dev-vcs/git media-libs/fontconfig x11-base/xorg-proto x11-libs/libX11 x11-libs/libXft x11-libs/libXinerama media-fonts/jetbrains-mono media-fonts/fontawesome media-gfx/feh x11-apps/xsetroot x11-apps/setxkbmap media-fonts/takao-fonts media-sound/pnmixer  gnome-extra/nm-applet sys-devel/gcc app-text/asciidoc dev-lang/python dev-libs/libconfig dev-libs/libev dev-libs/libpcre dev-libs/uthash dev-python/xcffib  dev-util/meson dev-util/meson-format-array dev-util/ninja sys-apps/dbus virtual/opengl virtual/pkgconfig x11-apps/xhost x11-base/xorg-server x11-libs/libXext x11-libs/libdrm x11-libs/libxcb x11-libs/pixman x11-libs/xcb-util-image x11-libs/xcb-util-renderutil x11-misc/dunst xfce-base/thunar xfce-extra/xarchiver xfce-extra/thunar-archive-plugin x11-misc/rofi app-admin/doas x11-misc/cbatticon app-shells/dash lxde-base/lxappearance x11-misc/sddm net-p2p/qbittorrent sys-apps/exa net-libs/nodejs media-fonts/hack dev-util/cmake
  elif [ "${DISTRO:?}" = "Arch" ] || [ "${DISTRO:?}" = "arch" ]
  then
    sudo pacman -S git fontconfig xorgproto libx11 libxft libxinerama ttf-jetbrains-mono ttf-font-awesome feh xorg-xsetroot xorg-setxkbmap network-manager-applet dunst thunar xarchiver thunar-archive-plugin rofi doas cbatticon dash lxappearance sddm qbittorrent papirus-icon-theme nodejs npm ttf-hack-nerd cmake
    yay -S otf-takao volctl pnmixer exa mojave-gtk-theme-git bibata-cursor-theme-bin
  else
    sudo add-apt-repository ppa:aslatter/ppa
    sudo add-apt-repository ppa:qbittorrent-team/qbittorrent-stable
    sudo apt install git build-essential nodejs npm dunst thunar rofi nm-tray fonts-takao libxcb-render-util0-dev libxcb-image0-dev libpixman-1-dev libxcb-util-dev libxcb-damage0-dev libxcb-randr0-dev libxcb-sync-dev libxcb-composite0-dev libxcb-xinerama0-dev libxcb-present-dev libxcb-glx0-dev libegl1-mesa-dev libdbus-glib-1-dev libdrm-dev libxext-dev x11-xserver-utils pkg-config libgl-dev dbus ninja-build meson python3-xcffib uthash-dev libpcre3 libpcre3-dev libev-dev libconfig-dev asciidoc python3 gcc pnmixer feh fonts-font-awesome libxinerama-dev libxft-dev libx11-dev fontconfig xorg xserver-xorg x11proto-dev wget libx11-xcb-dev xarchiver thunar-archive-plugin doas cbatticon lxappearance sddm qbittorrent fonts-hack-ttf cmake
    wget https://download.jetbrains.com/fonts/JetBrainsMono-2.242.zip
    unzip JetBrainsMono-2.242.zip
    cd fonts
    sudo mv ttf /usr/share/fonts/jetbrains-mono
    sudo fc-cache -f -v
    cd ../Dwm_Rice
  fi
  #Installing Vim plugin manager Dein
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/Shougo/dein-installer.vim/master/installer.sh)"
}

picom_setup() {
  #Installing Picom-Yshui
  cd ..
  git clone https://github.com/yshui/picom.git
  cd picom/
  meson setup --buildtype=release build
  ninja -C build
  sudo ninja -C build install
  cd ../Dwm_Rice
}

launcher_and_powermenu_setup() {
  ##Installing launcher
  cd ..
  git clone --depth=1 https://github.com/adi1090x/rofi.git
  cd rofi
  chmod +x setup.sh
  ./setup.sh
  cd ../Dwm_Rice
  sudo cp config/launcher/rose.rasi ~/.config/rofi/colors/rose.rasi
  sudo cp config/launcher/colors.rasi ~/.config/rofi/launchers/type-1/shared/colors.rasi
  sudo cp config/launcher/launcher.sh /usr/local/bin
  sudo chmod +x /usr/local/bin/launcher.sh
  ##Installing powermenu
  cp config/powermenu/powermenu.rasi ~/.config/rofi
  sudo cp powermenu.sh /usr/local/bin
  sudo chmod +x /usr/local/bin/powermenu.sh
}

config_files_setup() {
  rice_dir=$(pwd)
  cd ~
  git clone https://github.com/DwmEnjoyer/.dotfiles.git
  cd .dotfiles
  if [ -d ~/.config/alacritty ] && [ -f ~/.config/alacritty/alacritty.yml ]
  then
    mv ~/.config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml.old
  fi
  if [ -d ~/.config/dunst ]
  then
    mv ~/.config/dunst ~/.config/dunst.old
  fi
  if [ -d ~/.config/fish ] && [ -f ~/.config/fish/config.fish ]
  then
    mv ~/.config/fish/config.fish ~/.config/fish/config.fish.old
  fi
  if [ -d ~/.config/glava ]
  then
    mv ~/.config/glava ~/.config/glava.old
  fi
  if [ -d ~/.config/nvim ] && [ -f ~/.config/nvim/init.vim ]
  then
    mv ~/.config/nvim/init.vim ~/.config/nvim/init.vim.old
  fi
  if [ -d ~/.config/picom ]
  then
    mv ~/.config/picom ~/.config/picom.old
  fi
  if [ -d ~/.config/pipewire ] && [ -f ~/.config/pipewire/pipewire.conf ]
  then
    mv ~/.config/pipewire/pipewire.conf ~/.config/pipewire/pipewire.conf.old
  fi
  if [ -d ~/.config/qBittorrent ]&& [ -f ~/.config/qBittorrent/macchiato.qbtheme ]
  then
    mv ~/.config/qBittorrent/macchiato.qbtheme ~/.config/qBittorrent/macchiato.qbtheme.old
  fi
  if [ -d ~/.config/starship ] && [ -f ~/.config/starship/starship.toml ]
  then
    mv ~/.config/starship/starship.toml ~/.config/starship/starship.toml.old
  fi
  mkdir -p ~/.config/alacritty ~/.config/dunst ~/.config/fish ~/.config/glava ~/.config/nvim ~/.config/picom ~/.config/pipewire ~/.config/qBittorrent ~/.config/starship
  stow .
  cd "${rice_dir:?}"
}

shell_setup() {
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
  ##Changing shell for actual user
  chsh -s /bin/fish "${USER:?}"
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
    sudo emerge --ask x11-terms/alacritty
  elif [ "${DISTRO:?}" = "Arch" ] || [ "${DISTRO:?}" = "arch" ]
  then
    sudo pacman -S alacritty
  else
    sudo apt install alacritty
  fi
  ##Installing alacritty-themes
  sudo npm i -g alacritty-themes
  ##Installing starship prompt
  curl -sS https://starship.rs/install.sh | sh
  ##Installing Flowetch
  cd ..
  git clone https://github.com/DwmEnjoyer/Flowetch.git
  cd Flowetch/
  sudo make clean install
  cd ../Dwm_Rice
}

dwm_setup() {
  ##Instalación Dwm y Dmenu
  cd ..
  git clone https://github.com/DwmEnjoyer/Dwm.git
  git clone https://github.com/DwmEnjoyer/Dmenu.git
  cd Dmenu/
  sudo make clean install
  cd ../Dwm
  sudo make clean install
  ##Instalación de archivos de inicio de DWM
  sudo cp scripts/dwmstart.sh /usr/local/bin
  sudo cp scripts/statusbar.sh /usr/local/bin
  sudo cp xsessions/dwm.desktop /usr/share/xsessions
  sudo chmod 755 /usr/local/bin/dwmstart.sh /usr/local/bin/statusbar.sh
  sudo chmod 644 /usr/share/xsessions/dwm.desktop
  cd ../Dwm_Rice
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
  if [ "${DEPENDENCIES:?}" -eq 1 ]
    then
      echo "Installing dependencies..."
      dependencies
      echo "Dependencies successfully installed."
    fi
    if [ "${PICOM_SETUP:?}" -eq 1 ]
    then
      echo "Installing picom..."
      picom_setup
      echo "Picom successfully installed."
    fi
    if [ "${LAUNCHER_SETUP:?}" -eq 1 ]
    then
      echo "Installing launcher..."
      launcher_and_powermenu_setup
      echo "Launcher successfully installed."
    fi
    if [ "${SHELL_SETUP:?}" -eq 1 ]
    then
      echo "Configuring shell..."
      shell_setup
      echo "Shell successfully configured."
    fi
    if [ "${TERMINAL_SETUP:?}" -eq 1 ]
    then
      echo "Customizing terminal..."
      terminal_setup
      echo "Terminal successfully customized."
    fi
    if [ "${CONFIG_FILES_SETUP:?}" -eq 1 ]
    then
      echo "Moving config files..."
      config_files_setup
      echo "Config files successfully moved."
    fi
    if [ "${DWM_SETUP:?}" -eq 1 ]
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
