{ config, pkgs, sops, ... }:

{
    imports =
    [
        ../common/proxmox.nix
    ];

    services.caddy.enable = true;
    services.caddy.email = "chris@christopherjones.us";
    services.caddy.logFormat = ''
        output stderr
        format json
        level ERROR
    '';
    services.caddy.virtualHosts.localhost.extraConfig = ''
        respond "Hello, world!"
    '';
    services.caddy.virtualHosts."writefreely.hilandchris.com".extraConfig = ''
        reverse_proxy localhost:9000
    '';
    services.caddy.virtualHosts."timestampr.hilandchris.com".extraConfig = ''
        redir https://timestampr.foobarbaz.dev{uri}
    '';
    services.caddy.virtualHosts."nodered.hilandchris.com".extraConfig = ''
        reverse_proxy http://192-168-104-94.infra.hilandchris.com:1880
    '';
    services.caddy.virtualHosts."homeassistant.hilandchris.com".extraConfig = ''
        reverse_proxy http://192-168-104-94.infra.hilandchris.com:8123
    '';
    services.caddy.virtualHosts."proxmox.hilandchris.com".extraConfig = ''
        reverse_proxy https://192-168-104-2.infra.hilandchris.com:8006
    '';
    services.caddy.virtualHosts."prometheus.hilandchris.com".extraConfig = ''
        reverse_proxy http://192-168-104-97.infra.hilandchris.com:9090
    '';
    services.caddy.virtualHosts."alerts.hilandchris.com".extraConfig = ''
        reverse_proxy http://192-168-104-97.infra.hilandchris.com:9093
    '';
    services.caddy.virtualHosts."deluge.hilandchris.com".extraConfig = ''
        reverse_proxy http://192-168-104-98.infra.hilandchris.com:8112
    '';
    services.caddy.virtualHosts."nzbget.hilandchris.com".extraConfig = ''
        reverse_proxy http://192-168-104-98.infra.hilandchris.com:6789
    '';
    services.caddy.virtualHosts."bazarr.hilandchris.com".extraConfig = ''
        reverse_proxy http://192-168-104-98.infra.hilandchris.com:6767
    '';
    services.caddy.virtualHosts."jackett.hilandchris.com".extraConfig = ''
        reverse_proxy http://192-168-104-98.infra.hilandchris.com:9117
    '';
    services.caddy.virtualHosts."radarr.hilandchris.com".extraConfig = ''
        reverse_proxy http://192-168-104-98.infra.hilandchris.com:7878
    '';
    services.caddy.virtualHosts."sonarr.hilandchris.com".extraConfig = ''
        reverse_proxy http://192-168-104-98.infra.hilandchris.com:8989
    '';
    services.caddy.virtualHosts."lidarr.hilandchris.com".extraConfig = ''
        reverse_proxy http://192-168-104-98.infra.hilandchris.com:868
    '';
    services.caddy.virtualHosts."prowlarr.hilandchris.com".extraConfig = ''
        reverse_proxy http://192-168-104-98.infra.hilandchris.com:9696
    '';
    services.caddy.virtualHosts."foundry.hilandchris.com".extraConfig = ''
        reverse_proxy http://192-168-104-24.infra.hilandchris.com:30000
    '';

    services.caddy.virtualHosts."plex.hilandchris.com".extraConfig = ''
        reverse_proxy {
            to https://192-168-104-95.infra.hilandchris.com:32400
            transport http {
            tls
            tls_insecure_skip_verify
            }
        }
    '';

    # External services
    services.caddy.virtualHosts."writefreely.vpn.hilandchris.com".extraConfig = ''
        reverse_proxy localhost:9000
    '';
    services.caddy.virtualHosts."timestampr.vpn.hilandchris.com".extraConfig = ''
        reverse_proxy localhost:9001
    '';
    services.caddy.virtualHosts."deconz.hilandchris.com".extraConfig = ''
        reverse_proxy http://192-168-102-101.infra.hilandchris.com:23331
    '';
    services.caddy.virtualHosts."grafana.hilandchris.com".extraConfig = ''
        reverse_proxy http://192-168-104-97.infra.hilandchris.com:3000
    '';
    services.caddy.virtualHosts."git.hilandchris.com".extraConfig = ''
        reverse_proxy http://192-168-104-99.infra.hilandchris.com:6000
    '';
}
