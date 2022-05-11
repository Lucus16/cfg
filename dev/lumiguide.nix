{ config, pkgs, ... }:

{
  nix.settings = {
    netrc-file = "${../secrets/lumiguide/nix-netrc}";
    substituters = [ "https://cache.lumi.guide" ];
    trusted-substituters = [ "https://cache.lumi.guide" ];
    trusted-users = [ "lumi" ];
    trusted-public-keys =
      [ "cache.lumi.guide-1:z813xH+DDlh+wvloqEiihGvZqLXFmN7zmyF8wR47BHE=" ];
  };

  users.users.lumi = {
    extraGroups = [ "adbusers" "dialout" "kvm" "systemd-journal" ];
    isNormalUser = true;
    openssh.authorizedKeys.keyFiles = [ ../dot/ssh/.ssh/authorized_keys ];
  };

  networking.wireguard.enable = true;
  networking.wireguard.interfaces.lumiguide = {
    generatePrivateKeyFile = true;
    ips = [
      {
        amateria = "10.109.0.23";
        channelwood = "10.109.0.24";
      }.${config.networking.hostName}
    ];
    privateKeyFile = "/etc/wireguard/lumiguide.secret";
    postSetup = "ip link set mtu 1360 dev lumiguide";
    peers = [{
      allowedIPs = [ "10.96.0.0/12" "10.0.0.0/17" "172.31.8.0/21" ];
      endpoint = "wg.lumi.guide:31727";
      persistentKeepalive = 24;
      publicKey = "6demp+PX2XyVoMovDj4xHQ2ZHKoj4QAF8maWpjcyzzI=";
    }];
  };
}
