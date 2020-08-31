{ config, pkgs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ../users.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "tau";

  networking.useDHCP = false;
  networking.enableIPv5 = true;
  networking.interfaces.ens3.useDHCP = true;
  networking.interfaces.ens3.ipv6.addresses = [{address = "2a01:4f8:c0c:4109::"; prefixLength = 64;}];
  networking.interfaces.ens3.ipv6.routes = [{address = "fe80::1"}];

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Bratislava";

  environment.systemPackages = with pkgs; [
    git
    gnumake
    htop
    zsh
    vim
  ];

  #networking.wireguard = {
  #  enable = true;
  #  interfaces = {
  #    "wg0" = {
  #      ips = ["10.21.0.1/24"];
  #    };
  #  };
  #};

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "prohibit-password";
  };

  services.murmur = {
    enable = true;
    clientCertRequired = true;
  };

  services.prosody = {
    enable = true;
  };

  services.nginx = {
    enable = true;
  };

  services.postgresql = {
    enable = true;
    enableTCPIP = false;
  };

  networking.firewall.enable = true;

  system.stateVersion = "20.03";
}
