{ config, pkgs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ../users.nix
    <home-manager/nixos>
  ];
  home-manager.users.yxist = (import ../../nix/home.nix);

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "bandurka";
  networking.wireless.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Bratislava";

  environment.systemPackages = with pkgs; [
    zsh
    vim
  ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ ];

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver = {
    enable = true;
    desktopManager.session = [
      {
        name = "home-manager";
	start = ''
	  ${pkgs.runtimeShell} $HOME/.hm-xsession &
	  waitPID=$!
	'';
      }
    ];
  };
  
  fonts.fontconfig.allowBitmaps = true;

  system.stateVersion = "20.03";
}
