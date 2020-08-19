{ config, pkgs, ...}:

{
  home.packages = with pkgs; [
    firefox
    thunar
  ];
  programs.qutebrowser = {
    enable = true;
  };
}
