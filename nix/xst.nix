{ config, lib, pkgs, ... }:

let
  mod = "Mod4";
in
{
  home.packages = with pkgs; [
    xst
  ];
  xresources.properties = {
    "st.termname" = "xterm-256color";
    "st.borderless" = 1;
  };
}
