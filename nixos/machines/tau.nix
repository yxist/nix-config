{ config, lib, pkgs, ... }:

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
    ncdu
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

  services.netdata = {
    enable = true;
  };

  services.grafana = {
    enable = true;
    rootUrl = "https://mon.xdd.sk/";
    domain = "mon.xdd.sk";
    database = {
      type = "postgres";
      user = "grafana";
      host = "/run/postgresql/";
    };
  };

  services.postgresql = {
    enable = true;
    enableTCPIP = false;
    extraPlugins = [ pkgs.timescaledb ];
    extraConfig = "shared_preload_libraries = 'timescaledb'";
    identMap =''
      mymap prosody prosody
      mymap murmur murmur
      mymap grafana grafana
    '';
  };
  systemd.services.postgresql.postStart = lib.mkAfter ''
    $PSQL -tAc 'REVOKE ALL ON DATABASE template1 FROM public' || true
    $PSQL template1 -tAc 'REVOKE ALL ON SCHEMA public FROM public' || true
    $PSQL template1 -tAc 'ALTER DEFAULT PRIVILEGES REVOKE ALL ON TABLES FROM public' || true

    ${lib.concatMapStrings (database: ''
      $PSQL -tAc 'CREATE ROLE ${database} WITH NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN' || true
      $PSQL -tAc "SELECT 1 FROM pg_database WHERE datname = '${database}'" | grep -q 1 || $PSQL -tAc 'CREATE DATABASE "${database}"'
      $PSQL -tAc 'GRANT ALL PRIVILEGES ON DATABASE ${database} TO "${database}"' || true
      $PSQL ${database} -tAc 'GRANT ALL PRIVILEGES ON SCHEMA public TO ${database}' || true
    '') [ "prosody" "murmur" "grafana"]}

    $PSQL -tAc "SELECT 1 FROM pg_database WHERE datname = 'mon'" | grep -q 1 || $PSQL -tAc 'CREATE DATABASE "mon"'
    $PSQL -tAc 'CREATE ROLE mon_readonly WITH NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN' || true
    $PSQL -tAc 'GRANT CONNECT ON DATABASE mon TO "mon_readonly"' || true
    $PSQL mon -tAc 'GRANT USAGE ON SCHEMA public TO mon_readonly' || true
  '';

  services.pgmanage = {
    allowCustomConnections = true;
    enable = true;
  };

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = ["/"];
    interval = "monthly";
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "prohibit-password";
  };

  services.murmur = {
    enable = true;
    bandwidth = 140000;
    hostName = "";
    registerName = "xdd.sk";
    clientCertRequired = true;
    sslKey = "${config.security.acme.certs."xdd.sk".directory}/key.pem";
    sslCert = "${config.security.acme.certs."xdd.sk".directory}/fullchain.pem";
    extraConfig =
      ''
      dbDriver=QPSQL
      database=murmur
      dbName=murmur
      dbUsername=murmur
      dbPort=5432
      '';
  };

  services.prosody = {
    enable = true;
    virtualHosts = {
      "xdd.sk" = {
        domain = "xdd.sk";
        enabled = true;
        ssl.key = "${config.security.acme.certs."xdd.sk".directory}/key.pem";
        ssl.cert = "${config.security.acme.certs."xdd.sk".directory}/fullchain.pem";
      };
    };
    extraConfig =
      ''
      storage = "sql"
      sql = {
          driver = "PostgreSQL";
          database = "prosody";
          username = "prosody";
      }
      '';
  };
  
  users.groups.xdd-sk-certs.members = [ "prosody" "murmur" ];
  security.acme = {
    acceptTerms = true;
    email = "letsencrypt@xdd.sk";
    certs."xdd.sk" = {
      allowKeysForGroup = true;
      group = "xdd-sk-certs";
      postRun = "systemctl reload-or-restart prosody; systemctl reload-or-restart murmur";
    };
  };

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
      "mon.xdd.sk" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3000"; # grafana
          proxyWebsockets = true;
        };
      };
    };
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 5222 5269 64738 ];
  networking.firewall.allowedUDPPorts = [ 443 64738 ];

  system.stateVersion = "20.03";
}
