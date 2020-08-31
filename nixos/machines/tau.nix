{ config, pkgs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ../users.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "tau";

  networking.useDHCP = false;
  networking.interfaces.ens10.useDHCP = true;

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Bratislava";

  environment.systemPackages = with pkgs; [
    zsh
    vim
  ];

  networking.wireguard = {
    enable = true;
    interfaces = {
      "wg0" = {
        ips = ["10.21.0.1/24"];
      };
    };
  };

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
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 5222 5269 64738 ];
  networking.firewall.allowedUDPPorts = [ 443 51820 64738 ];

  system.stateVersion = "20.03";
}
