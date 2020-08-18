{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    autojump
    gnumake
    git
    htop
    libnotify
  ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    plugins = [
      {
        name = "auto-notify";
	src = pkgs.fetchFromGitHub {
	  owner = "MichaelAquilina";
	  repo = "zsh-auto-notify";
	  rev = "0.8.0";
	  sha256 = "02x7q0ncbj1bn031ha7k3n2q2vrbv1wbvpx9w2qxv9jagqnjm3bd";
	};
      }
      {
        name = "spaceship-prompt";
	src = pkgs.fetchFromGitHub {
	  owner = "denysdovhan";
	  repo = "spaceship-prompt";
	  rev = "v3.11.2";
	  sha256 = "1q7m9mmg82n4fddfz01y95d5n34xnzhrnn1lli0vih39sgmzim9b";
	};
        file = "./spaceship.zsh";
      }
    ];
  };
}
