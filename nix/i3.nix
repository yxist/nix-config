{ config, lib, pkgs, ... }:

let
  mod = "Mod4";
in
{
  home.packages = with pkgs; [
    siji
    terminus_font
    terminus_font_ttf
    tamsyn

    ${pkgs.fetchFromGitHub {
      owner = "Tecate";
      repo = "bitmap-fonts";
      rev = "5c101c91bf2ed0039aad02f9bf76ddb2018b1f21";
      sha256 = "0s119zln3yrhhscfwkjncj72cr68694643009aam63s2ng4hsmfl";
    }}
  ];

  fonts.fontconfig.enable = true;

  xsession.enable = true;
  xsession.scriptPath = ".hm-xsession";
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      modifier = mod;
      fonts = [ "Terminus (TTF)" ];
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
  xresources.properties = {
    "*background" = "#282828";
    "*foreground" = "#ebdbb2";
    "*bg1" = "#3c3836";
    "*bg2" = "#504845";
    "*orange" = "#d65d0e";
    "*color0" = "#282828";
    "*color8" = "#928374";
    "*color1" = "#cc241d";
    "*color9" = "#fb4934";
    "*color2" = "#98971a";
    "*color10" = "#b2bb26";
    "*color3" = "#d79921";
    "*color11" = "#fabd2f";
    "*color4" = "#458588";
    "*color12" = "#83a598";
    "*color5" = "#b16286";
    "*color13" = "#d3869b";
    "*color6" = "#689d6a";
    "*color14" = "#8ec07c";
    "*color7" = "#a89984";
    "*color15" = "#ebdbb2";
  };
  programs.termite = {
    enable = true;
    font = "Terminus 9";
    fullscreen = false;
    sizeHints = false;
    backgroundColor = "#282828";
    foregroundColor = "#ebdbb2";
    colorsExtra =
      ''
      color0  = #282828
      color1  = #cc241d
      color2  = #98971a
      color3  = #d79921
      color4  = #458588
      color5  = #b16286
      color6  = #689d6a
      color7  = #a89984
      color8  = #928374
      color9  = #fb4934
      color10 = #b2bb26
      color11 = #fabd2f
      color12 = #83a598
      color13 = #d3869b
      color14 = #8ec07c
      color15 = #ebdbb2
      '';
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
  services.udiskie = {
    enable = true;
  };
  services.unclutter = {
    enable = true;
  };
  services.polybar = {
    enable = true;
    script = "polybar top & polybar bottom &";
    package = pkgs.polybar.override {
      pulseSupport = true;
      mpdSupport = true;
      i3GapsSupport = true;
    };
    config = {
      
      "colors" = {
        background = "\${xrdb:background:#222}";
        background-alt = "\${xrdb:bg2:#444}";
        foreground = "\${xrdb:foreground:#dfdfdf}";
        foreground-alt = "\${xrdb:color8:#555}";
        primary = "\${xrdb:color4:#bbbbdd}";
        secondary = "\${xrdb:orange:#e60053}";
        alert = "\${xrdb:color1:#bd2c40}";
      };

      "bar/top" = {
        width = "100%";
        height = 20;
        radius = "0.0";
        fixed-center = true;
        background = "\${colors.background}";
        foreground = "\${colors.foreground}";
        line-size = 1;
        line-color = "#f00";
        border-size = 4;
        border-bottom-size = 0;
        border-color = "#00000000"; 
        padding-left = 0;
        padding-right = 1;
        module-margin-left = 1;
        module-margin-right = 1;
        font-0 = "terminus:pixelsize=11;1";
        font-1 = "siji:pixelsize=10;1";
        font-2 = "fixed:pixelsize=10;1";
        modules-left = "i3";
        modules-center = "date";
        modules-right = "pulseaudio xkeyboard";
        tray-position = "right";
        tray-padding = 2;
        cursor-click = "pointer";
        cursor-scroll = "ns-resize";
      };

      "bar/bottom" = {
        width = "100%";
        height = 20;
        radius = "0.0";
        fixed-center = true;
        background = "\${colors.background}";
        foreground = "\${colors.foreground}";
        line-size = 1;
        line-color = "#f00";
        border-size = 4;
        border-bottom-size = 0;
        border-color = "#00000000"; 
        padding-left = 1;
        padding-right = 1;
        module-margin-left = 1;
        module-margin-right = 1;
        font-0 = "terminus:pixelsize=11;1";
        font-1 = "siji:pixelsize=10;1";
        font-2 = "fixed:pixelsize=10;1";
        modules-left = "battery wlan eth";
        modules-center = "";
        modules-right = "filesystem memory cpu temperature";
        cursor-click = "pointer";
        cursor-scroll = "ns-resize";
        bottom = true;
      };

      "module/xkeyboard" = {
        type = "internal/xwindow";
        format-prefix = " ";
        format-prefix-foreground = "\${colors.foreground-alt}";
        label-layout = "%layout%";
        label-indicator-padding = 2;
        label-indicator-margin = 1;
        label-indicator-background = "\${colors.secondary}";
      };
      
      "module/filesystem" = {
        type = "internal/fs";
        interval = 25;
        mount-0 = "/";
        label-mounted-foreground = "\${colors.foreground-alt}";
        label-mounted = " %{F-}%free:5%";
      };

      "module/i3" = {
        type = "internal/i3";
        format = "<label-state> <label-mode>";
        index-sort = true;
        wrapping-scroll = false;
        pin-workspaces = true;
        label-mode-padding = 2;
        label-mode-foreground = "#000";
        label-mode-background = "\${colors.primary}";
        label-focused = "%index%";
        label-focused-background = "\${colors.background-alt}";
        label-focused-underline = "\${colors.primary}";
        label-focused-padding = 1;
        label-unfocused = "%index%";
        label-unfocused-padding = 1;
        label-visible = "%index%";
        label-visible-background = "\${self.label-focused-background}";
        label-visible-underline = "\${self.label-focused-underline}";
        label-visible-padding = "\${self.label-focused-padding}";
        label-urgent = "%index%";
        label-urgent-background = "\${colors.alert}";
        label-urgent-padding = 1;
        label-separator-padding = 0;
      };

      "module/backlight" = {
        type = "internal/xbacklight";
        card = "amdgpu_bl0"; # bandurka specific TODO

	format = "<label>";

	format-prefix = " ";
	format-prefix-foreground = "#666";
	bar-width = 5;
	bar-indicator = "|";
	bar-indicator-foreground = "#fff";
	bar-indicator-font = 2;
	bar-fill = "─";
	bar-fill-font = 2;
	bar-fill-foreground = "#c1c140";
	bar-empty = "─";
	bar-empty-font = 2;
	bar-empty-foreground = "\${colors.foreground-alt}";
      };

      "module/cpu" = {
        type = "internal/cpu";
        interval = 1;
        format-prefix = " ";
        format-prefix-foreground = "\${colors.foreground-alt}";
        label = "%percentage:3%%";
      };

      "module/memory" = {
        type = "interval/memory";
        interval = 1;
        format-prefix = " ";
        format-prefix-foreground = "\${colors.foreground-alt}";
        label = "%gb_free:7%";
      };

      "module/wlan" = {
        type = "internal/network";
        interface = "wlo1";
        interval = "3.0";

        format-connected = "<ramp-signal> <label-connected>";
        label-connected = "%essid% %{F#666}-%{F-} %local_ip%";
        format-disconnected = "";

        ramp-signal-0 = "";
        ramp-signal-1 = "";
        ramp-signal-2 = "";
        ramp-signal-3 = "";
        ramp-signal-4 = "";
        ramp-signal-foreground = "\${colors.foreground-alt}";
      };

      "module/eth" = {
        type = "internal/network";
        interface = "eno1";
        interval = "3.0";

        format-connected-prefix = " ";
        format-connected-prefix-foreground = "\${colors.foreground-alt}";
        label-connected = "%local_ip%";
        format-disconnected = "";
      };

      "module/date" = {
        type = "internal/date";
        interval = 1;

        date = "%a %Y-%m-%d";
        date-alt = "%a %Y-%m-%d";

        time = "%H:%M:%S %z";
        time-alt = "%H:%M:%S %z";

        format-prefix = "";
        format-prefix-foreground = "\${colors.foreground-alt}";
        format-underline = "";

        label = "%date% %time%";
      };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";

        format-volume = "<ramp-volume> <label-volume>";
        label-volume =  "%percentage:3%%";
        label-volume-foreground = "\${root.foreground}";

        label-muted = " mut";
        label-muted-foreground = "#666";

        ramp-volume-0 = "";
        ramp-volume-1 = "🔇";
        ramp-volume-foreground = "#666";

        bar-volume-width = 10;
        bar-volume-foreground-0 = "#55aa55";
        bar-volume-foreground-1 = "#55aa55";
        bar-volume-foreground-2 = "#55aa55";
        bar-volume-foreground-3 = "#55aa55";
        bar-volume-foreground-4 = "#55aa55";
        bar-volume-foreground-5 = "#f5a70a";
        bar-volume-foreground-6 = "#ff5555";
        bar-volume-gradient = "false";
        bar-volume-indicator = "|";
        bar-volume-indicator-font = 2;
        bar-volume-fill = "─";
        bar-volume-fill-font = 2;
        bar-volume-empty = "─";
        bar-volume-empty-font = 2;
        bar-volume-empty-foreground = "\${colors.foreground-alt}";
      };

      "module/battery" = {
        type = "internal/battery";
        battery = "BAT0";
        adapter = "AC";
        full-at = 100;

        label-charging = "%percentage:3%%";
        label-discharging = "%percentage:3%%";

        format-charging = "<animation-charging> <label-charging>";
        format-discharging = "<animation-discharging> <label-discharging>";
        format-full-prefix = " ";
        format-full-prefix-foreground = "\${colors.foreground-alt}";

        ramp-capacity-0 = "";
        ramp-capacity-1 = "";
        ramp-capacity-2 = "";
        ramp-capacity-foreground = "\${colors.foreground-alt}";

        animation-charging-0 = "";
        animation-charging-1 = "";
        animation-charging-2 = "";
        animation-charging-foreground = "\${colors.foreground-alt}";
        animation-charging-framerate = 750;

        animation-discharging-0 = "";
        animation-discharging-1 = "";
        animation-discharging-2 = "";
        animation-discharging-foreground = "\${colors.foreground-alt}";
        animation-discharging-framerate = 750;
      };

      "module/temperature" = {
        type = "internal/temperature";
        thermal-zone = 0;
        warn-temperature = 60;

        format = "<ramp> <label>";
        format-warn = "<ramp> <label-warn>";

        label = "%temperature-c%";
        label-warn = "%temperature-c%";

        ramp-0 = "";
        ramp-1 = "";
        ramp-2 = "";
        ramp-foreground = "\${colors.foreground-alt}";
      };

      "settings" = {
        screenchange-reload = true;
      };

      "global/wm" = {
        margin-top = 5;
        margin-bottom = 5;
      };
    };
  };
}
