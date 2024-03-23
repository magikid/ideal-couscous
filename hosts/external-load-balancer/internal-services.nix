{
    modulesPath,
    lib,
    config,
    pkgs,
    ...
}:
let
    defaultLogFormat = ''
        output stderr
        format json
        level info
    '';
in {
    services.caddy.virtualHosts."zigbee2mqtt.hilandchris.com".logFormat = defaultLogFormat;
    services.caddy.virtualHosts."zigbee2mqtt.hilandchris.com".extraConfig = ''
        bind external-load-balancer.exocomet-cloud.ts.net

        reverse_proxy zigbee2mqtt.exocomet-cloud.ts.net:8080
    '';

    services.caddy.virtualHosts."homeassistant.hilandchris.com".logFormat = defaultLogFormat;
    services.caddy.virtualHosts."homeassistant.hilandchris.com".extraConfig = ''
        bind external-load-balancer.exocomet-cloud.ts.net

        reverse_proxy home-assistant.exocomet-cloud.ts.net:8123
    '';

    services.caddy.virtualHosts."nodered.hilandchris.com".logFormat = defaultLogFormat;
    services.caddy.virtualHosts."nodered.hilandchris.com".extraConfig = ''
        bind external-load-balancer.exocomet-cloud.ts.net

        reverse_proxy home-assistant.exocomet-cloud.ts.net:1880
    '';

    services.caddy.virtualHosts."nextcloud.hilandchris.com".logFormat = defaultLogFormat;
    services.caddy.virtualHosts."nextcloud.hilandchris.com".extraConfig = ''
        bind external-load-balancer.exocomet-cloud.ts.net

        reverse_proxy nextcloud.exocomet-cloud.ts.net
    '';
}
