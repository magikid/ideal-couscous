{ config, pkgs, ... }:

{
  imports = [ ];
  boot.isContainer = true;
  system.stateVersion = "23.11";
}
