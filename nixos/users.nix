{ config, pkgs, ... }:
let
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICcLBJfmOCkmzYgRMG7uxERuporltNCm52Ddk9BdsUNm"
  ];
in
{
 users.users = {
   root = {
     openssh.authorizedKeys.keys = sshKeys;
   };
   yxist = {
     isNormalUser = true;
     uid = 1000;
     shell = pkgs.zsh;
     extraGroups = [ "wheel" ];
     openssh.authorizedKeys.keys = sshKeys;
   };
 };
}
