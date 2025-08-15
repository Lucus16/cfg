{ pkgs, ... }:

{
  # ejabberdctl register username hostname.com Password1
  services.ejabberd = {
    enable = true;
    package = pkgs.ejabberd.override {
      withSqlite = true;
    };
    configFile = pkgs.writeText "ejabberd.yaml" (builtins.toJSON {
      hosts = [ "u16.nl" ];
      listen = [
        {
          port = 5222;
          ip = "::";
          module = "ejabberd_c2s";
          max_stanza_size = 65536;
          starttls_required = true;
        }
        {
          port = 5269;
          ip = "::";
          module = "ejabberd_s2s_in";
          max_stanza_size = 131072;
        }
        {
          port = 5443;
          ip = "::";
          module = "ejabberd_http";
          # request_handlers."/push" = "mod_unified_push";
          request_handlers."/upload" = "mod_http_upload";
        }
      ];

      auth_method = [ "internal" ];
      auth_password_format = "scram";
      certfiles = [ "/var/lib/acme/u16.nl/full.pem" ];
      default_db = "sql";
      loglevel = "warning";
      s2s_use_starttls = "required";
      sql_type = "sqlite";

      modules = {
        mod_blocking = { };
        mod_carboncopy = { };
        mod_http_upload.put_url = "https://@HOST@/ejabberd/upload";
        mod_mam.assume_mam_usage = true;
        mod_mam.default = "always";
        mod_offline = { };
        mod_ping = { };
        mod_privacy = { };
        mod_roster = { };
        mod_stream_mgmt.resume_timeout = 3600;
        # mod_unified_push = { };
        mod_vcard = { };
        mod_version = { };
      };
    });
  };

  users.groups.u16cert.members = [ "ejabberd" "nginx" ];
  security.acme.certs."u16.nl".group = "u16cert";

  services.nginx = {
    enable = true;
    virtualHosts."u16.nl" = {
      enableACME = true;
      forceSSL = true;
      locations."/ejabberd/".proxyPass = "http://localhost:5443/";
      extraConfig = ''
        client_max_body_size 1G;
      '';
    };
  };
}
