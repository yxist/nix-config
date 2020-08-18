{ config, pkgs, ...}:

{
  nixpkgs.config.allowUnfree = true;
  programs.home-manager.enable = true;
  imports = [
    ./i3.nix
    ./shell.nix
  ];
  home.stateVersion = "20.09";
}
