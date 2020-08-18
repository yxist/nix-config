#!/bin/sh
sudo nix-channel --add https://github.com/rycee/home-manager/archive/release-20.03.tar.gz home-manager
sudo nix-channel --update

nix-shell -p git
git clone https://github.com/yxist/nix-config $HOME/nix-config
cd $HOME/nix-config
sudo mv /etc/nixos/configuration.nix /tmp/
sudo ln -s $(pwd)/nixos/machines/bandurka.nix /etc/nixos/configuration.nix

make
