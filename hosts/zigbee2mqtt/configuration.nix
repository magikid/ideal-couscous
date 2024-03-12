{ config, pkgs, sops, home-manager, ... }:

{
    imports =
    [
        ../common/proxmox.nix
    ];

    sops.templates."secret.yaml".content = ''
        user: ${config.sops.placeholder."mqtt/zigbee2mqtt/username"}
        password: ${config.sops.placeholder."mqtt/zigbee2mqtt/password"}
    '';
    sops.templates."secret.yaml".owner = "zigbee2mqtt";

    networking.hostName = "zigbee2mqtt"; # Define your hostname.
    networking.firewall.allowedTCPPorts = [ 22 8080 ];
    networking.interfaces.ens18.ipv4.addresses = [ {
        address = "192.168.104.27";
        prefixLength = 24;
    }];
    services.zigbee2mqtt = {
        enable = true;
        settings = {
            permit_join = true;
            availability = true;
            homeassistant = true;
            serial = {
                port = "/dev/ttyACM0";
            };
            mqtt = {
                server = "mqtt://database.exocomet-cloud.ts.net:1883";
                user = "!${config.sops.templates."secret.yaml".path} user";
                password = "!${config.sops.templates."secret.yaml".path} password";
            };
            frontend = {
                port = 8080;
                url = "https://zigbee2mqtt.hilandchris.com";
            };
            advanced = {
                last_seen = "ISO_8601_local";
            };
            device_options = {
                homeassistant = {
                    last_seen = {
                        enabled_by_default = true;
                    };
                };
            };
        };
    };
}
