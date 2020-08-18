{ config, ... }:

{
 users.users = {
   root = {
     openssh.authorizedKeys = users.users.yxist.openssh.authorizedKeys;
   }
   yxist = {
     isNormalUser = true;
     uid = 1000;
     shell = pkgs.fish;
     extraGroups = [ "wheel" ];
     openssh.authorizedKeys.keys = [
       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICcLBJfmOCkmzYgRMG7uxERuporltNCm52Ddk9BdsUNm"
     ];
   };
 };
}
