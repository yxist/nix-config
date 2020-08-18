{ config, lib, pkgs, ... }:

let
  mod = "Mod4";
in
{
  xsession.enable = true;
  xsession.scriptPath = ".hm-xsession";
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      modifier = mod;
      fonts = [ "monospace 8" ];
      bars = [];
      gaps.outer = 0;
      gaps.inner = 4;
      window.border = 0;
      window.titlebar = false;
      keybindings = lib.mkOptionDefault {
        "${mod}+Return"  = "exec --no-startup-id termite";
	"${mod}+p"       = "exec --no-startup-id xset dpms force off";
	"${mod}+d"       = "exec --no-startup-id rofi -show run";
	"${mod}+Shift+d" = "exec --no-startup-id rofi -show drun";
      };
    };
  };
  programs.termite = {
    enable = true;
  };
  programs.rofi = {
    enable = true;
  };
  services.screen-locker = {
    enable = true;
    lockCmd = "\${pkgs.i3lock}/bin/i3lock -n -c 000000";
  };
  services.dunst = {
    enable = true;
  };
  services.picom = {
    enable = true;
  };
  services.polybar = {
    enable = true;
    script = "polybar bar &";
  };
}
