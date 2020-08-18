{ config, pkgs, ...}:

let
  bandurkaImports = [
    ./i3.nix
  ];
in
{
  nixpkgs.config.allowUnfree = true;
  programs.home-manager.enable = true;
  imports = if (networking.hostname == "bandurka")
            then bandurkaImports
            else [];
}
