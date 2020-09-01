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
  networking.enableIPv6 = true;
  networking.interfaces.ens3.useDHCP = true;
  networking.interfaces.ens3.ipv6.addresses = [{address = "2a01:4f8:c0c:4109::"; prefixLength = 64;}];
  networking.interfaces.ens3.ipv6.routes = [{address = "::"; prefixLength = 0; via = "fe80::1";}];

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
    bandwidth = 140000;
    hostName = "";
    clientCertRequired = true;
    sslCa = /var/lib/acme/.lego/xdd.sk/certificates/xdd.sk.issuer.crt;
    sslCert = /var/lib/acme/.lego/xdd.sk/certificates/xdd.sk.crt;
    sslKey = /var/lib/acme/.lego/xdd.sk/certificates/xdd.sk.key;
  };

  services.prosody = {
    enable = true;
    virtualHosts = {
      "xdd.sk" = {
        domain = "xdd.sk";
	enabled = true;
	ssl.cert = /var/lib/acme/.lego/xdd.sk/certificates/xdd.sk.crt;
	ssl.key = /var/lib/acme/.lego/xdd.sk/certificates/xdd.sk.key;
      };
    };
  };
  
  security.acme.acceptTerms = true;
  security.acme.email = "letsencrypt@xdd.sk";
  services.nginx = {
    enable = true;
    virtualHosts = {
      "xdd.sk" = {
        forceSSL = true;
	enableACME = true;
	locations."/" = {
	  root = "/var/www/xdd.sk";
	};
      };
    };
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 5222 5269 64738 ];
  networking.firewall.allowedUDPPorts = [ 443 64738 ];

  system.stateVersion = "20.03";
}
