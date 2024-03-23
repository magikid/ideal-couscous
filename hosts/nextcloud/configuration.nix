{ config, pkgs, sops, home-manager, ... }:

{
    imports =
    [
        ../common/proxmox.nix
    ];

    sops.templates."nextcloud-admin-password.txt".content = ''
        ${config.sops.placeholder."nextcloud/admin_password"}
    '';
    sops.templates."secret.yaml".owner = "nextcloud";

    networking.hostName = "nextcloud"; # Define your hostname.
    networking.firewall.allowedTCPPorts = [ 22 80 ];
    networking.interfaces.ens18.ipv4.addresses = [ {
        address = "192.168.104.28";
        prefixLength = 24;
    }];

    services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud28;
        hostName = "nextcloud.hilandchris.com";
        config = {
            adminpassFile = "${config.sops.templates."nextcloud-admin-password.txt".path}";
            dbtype = "pgsql";
            dbhost = "";
            dbpassFile = "${config.sops.templates."postgresql-password.txt".path}";
            dbport = "5432";
            dbuser = "nextcloud";
            defaultPhoneRegion = "US";
            overwriteProtocol = "https";
        };
        database = {};
        extraApps = {
            inherit (config.services.nextcloud.package.packages.apps) bookmarks calendar contacts cookbook deck memories news notes notify_push polls previewgenerator tasks twofactor_webauthn unsplash;
        };
        extraAppsEnable = true;
        caching = {
            redis = true;
        };
        maxUploadSize = "1G";
        extraOptions.enabledPreviewProviders = [
            "OC\\Preview\\BMP"
            "OC\\Preview\\GIF"
            "OC\\Preview\\JPEG"
            "OC\\Preview\\Krita"
            "OC\\Preview\\MarkDown"
            "OC\\Preview\\MP3"
            "OC\\Preview\\OpenDocument"
            "OC\\Preview\\PNG"
            "OC\\Preview\\TXT"
            "OC\\Preview\\XBitmap"
            "OC\\Preview\\HEIC"
        ];
        extraOptions.redis = {
            host = "localhost";
            port = 6379;
            password = "${config.sops.placeholder."nextcloud/redis_password"}";
        };
        notify_push.enable = true;
    };
}
