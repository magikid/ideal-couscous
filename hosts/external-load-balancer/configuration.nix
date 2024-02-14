{ modulesPath, lib, config, pkgs, ... }:

{
    imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
        (modulesPath + "/virtualisation/digital-ocean-config.nix")
        ../common/configuration.nix
    ];

    networking.firewall.allowedTCPPorts = [ 80 443 ];
    services.caddy.enable = true;
    services.caddy.enableReload = true;
    services.caddy.globalConfig = ''
        grace_period 5s
    '';
    services.caddy.extraConfig = ''
        (security) {
            header {
                    Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
                    X-Xss-Protection "1; mode=block"
                    X-Content-Type-Options "nosniff"
                    Referrer-Policy "no-referrer-when-downgrade"
                    Content-Security-Policy "default-src 'none'; form-action 'none'; frame-ancestors 'none'; report-uri https://chriswjones.report-uri.com/r/d/csp/wizard"
                    X-Frame-Options "DENY"
                    Permissions "interest-cohort=()"
                    Feature-Policy "accelerometer 'none'; ambient-light-sensor 'none'; autoplay 'self'; camera 'none'; encrypted-media 'none'; fullscreen 'self'; geolocation 'none'; gyroscope 'none';       magnetometer 'none'; microphone 'none'; midi 'none'; payment 'none'; picture-in-picture *; speaker 'none'; sync-xhr 'none'; usb 'none'; vr 'none'"
                    Server "No."
            }
            error /.* "Not found" 404
        }

        (general) {
            encode zstd gzip
        }
    '';
    services.caddy.email = "chris@christopherjones.us";
    services.caddy.logFormat = ''
        output stderr
        format json
        level ERROR
    '';
    services.caddy.virtualHosts.localhost.extraConfig = ''
        respond "Hello, world!"
    '';
    services.caddy.virtualHosts."www.christopherjones.us".extraConfig = ''
        import general

        root * /var/www/christopherjones.us/
        try_files {path} /index.html
        file_server
    '';
    services.caddy.virtualHosts."christopherjones.us".extraConfig = ''
        redir https://www.{host}{uri}
    '';

    services.caddy.virtualHosts."www.dndont.com".extraConfig = ''
        import general

        root * /var/www/dndont.com/
        try_files {path} /index.html
        file_server
    '';
    services.caddy.virtualHosts."dndont.com".extraConfig = ''
        redir https://www.{host}{uri}
    '';

    services.caddy.virtualHosts."www.foobarbaz.dev".extraConfig = ''
        redir https://www.christopherjones.us/ 307
    '';
    services.caddy.virtualHosts."foobarbaz.dev".extraConfig = ''
        redir https://www.christopherjones.us/ 307
    '';

    services.caddy.virtualHosts."www.hilandchris.com".extraConfig = ''
        redir https://www.christopherjones.us/ 307
    '';
    services.caddy.virtualHosts."hilandchris.com".extraConfig = ''
        redir https://www.christopherjones.us/ 307
    '';

    services.caddy.virtualHosts."timestampr.foobarbaz.dev".extraConfig = ''
        import general

        reverse_proxy http://load-balancer-1.exocomet-cloud.ts.net:9001
    '';

    services.caddy.virtualHosts."snipeit.hilandchris.com".extraConfig = ''
        import security
        import general

        reverse_proxy http://snipeit.exocomet-cloud.ts.net
    '';

    services.caddy.virtualHosts."play.dndont.com".extraConfig = ''
        import general
        import security

        reverse_proxy http://foundry.exocomet-cloud.ts.net:30000
    '';
}
