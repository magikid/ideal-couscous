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
    hugo-christopherjones-us = (pkgs.callPackage ./hugo-christopherjones-us.nix {});
    custom-caddy = (pkgs.callPackage ./custom-caddy.nix {
        plugins = [
            "github.com/caddy-dns/cloudflare"
        ];
    });
in
{
    nix.settings.sandbox = false;

    imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
        (modulesPath + "/virtualisation/digital-ocean-config.nix")
        ../common/configuration.nix
        ./internal-services.nix
    ];

    boot.kernel.sysctl = {
        "net.core.rmem_max" = 2500000;
        "net.core.wmem_max" = 2500000;
    };

    services.tailscale.enable = true;

    environment.systemPackages = [
        pkgs.nss
        pkgs.openssl
    ];

    sops.templates."digitalocean-dns-token.json".owner = "caddy";
    sops.templates."cloudflare-dns-token.json".content = ''
        acme_dns cloudflare "${config.sops.placeholder."cloudflare/dns_token"}"
    '';
    sops.templates."cloudflare-dns-token.json".owner = "caddy";
    sops.templates."cloudflare-tls-dns-token.json".content = ''
        tls {
            dns cloudflare "${config.sops.placeholder."cloudflare/dns_token"}"
            resolvers 1.1.1.1
        }
    '';
    sops.templates."cloudflare-tls-dns-token.json".owner = "caddy";

    systemd.services.caddy.serviceConfig = {
        AmbientCapabilities="CAP_NET_BIND_SERVICE";
    };
    networking.firewall.allowedTCPPorts = [ 22 80 443 ];
    services.caddy = {
        enable = true;
        email = "chris@christopherjones.us";
        package = custom-caddy;
        globalConfig = ''
            import ${config.sops.templates."cloudflare-dns-token.json".path}
            import ${config.sops.templates."digitalocean-dns-token.json".path}

            skip_install_trust
            grace_period 5s
        '';
        extraConfig = ''
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
        logFormat = ''
            output stderr
            format json
            level debug
        '';
    };

    services.caddy.virtualHosts.localhost.extraConfig = ''
        respond "Hello, world!"
    '';

    services.caddy.virtualHosts."www.christopherjones.us".logFormat = defaultLogFormat;
    services.caddy.virtualHosts."www.christopherjones.us".extraConfig = ''
        import general

        root * ${hugo-christopherjones-us}
        try_files {path} /index.html
        file_server
    '';
    services.caddy.virtualHosts."christopherjones.us".extraConfig = ''
        redir https://www.{host}{uri}
    '';
    services.caddy.virtualHosts."christopherjones.us".logFormat = "output discard";

    services.caddy.virtualHosts."www.dndont.com".logFormat = defaultLogFormat;
    services.caddy.virtualHosts."www.dndont.com".extraConfig = ''
        import general

        root * /var/www/dndont.com/
        try_files {path} /index.html
        file_server
    '';
    services.caddy.virtualHosts."dndont.com".logFormat = "output discard";
    services.caddy.virtualHosts."dndont.com".extraConfig = ''
        redir https://www.{host}{uri}
    '';

    services.caddy.virtualHosts."www.foobarbaz.dev".logFormat = defaultLogFormat;
    services.caddy.virtualHosts."www.foobarbaz.dev".extraConfig = ''
        import ${config.sops.templates."cloudflare-tls-dns-token.json".path}

        root * ${hugo-christopherjones-us}
        try_files {path} /index.html
        file_server
    '';
    services.caddy.virtualHosts."foobarbaz.dev".logFormat = "output discard";
    services.caddy.virtualHosts."foobarbaz.dev".extraConfig = ''
        import ${config.sops.templates."cloudflare-tls-dns-token.json".path}

        root * ${hugo-christopherjones-us}
        try_files {path} /index.html
        file_server
    '';

    services.caddy.virtualHosts."www.hilandchris.com".logFormat = "output discard";
    services.caddy.virtualHosts."www.hilandchris.com".extraConfig = ''
        redir https://www.christopherjones.us/ 307
    '';
    services.caddy.virtualHosts."hilandchris.com".logFormat = "output discard";
    services.caddy.virtualHosts."hilandchris.com".extraConfig = ''
        redir https://www.christopherjones.us/ 307
    '';

    services.caddy.virtualHosts."www.timestampr.foobarbaz.dev".logFormat = defaultLogFormat;
    services.caddy.virtualHosts."timestampr.foobarbaz.dev".extraConfig = ''
        import general

        reverse_proxy http://load-balancer-1.exocomet-cloud.ts.net:9001
    '';

    services.caddy.virtualHosts."www.snipeit.hilandchris.com".logFormat = defaultLogFormat;
    services.caddy.virtualHosts."snipeit.hilandchris.com".extraConfig = ''
        import security
        import general

        reverse_proxy http://snipeit.exocomet-cloud.ts.net
    '';

    services.caddy.virtualHosts."www.play.dndont.com".logFormat = defaultLogFormat;
    services.caddy.virtualHosts."play.dndont.com".extraConfig = ''
        import general
        import security

        reverse_proxy http://foundry.exocomet-cloud.ts.net:30000
    '';

    services.caddy.virtualHosts."myqueue.rocks".logFormat = "output discard";
    services.caddy.virtualHosts."myqueue.rocks".extraConfig = ''
        redir https://www.christopherjones.us/ 307
    '';
}
