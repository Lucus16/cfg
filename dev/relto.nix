{ config, pkgs, lib, ... }:

let
  postgresUsers = [ "lars" "quassel" ];

  spire = "19106@ch-s012.rsync.net";

  common-borg-options = {
    encryption.mode = "repokey";
    encryption.passCommand = "cat /etc/borg_passphrase";
    environment.BORG_REMOTE_PATH = "borg1";
    environment.BORG_RSH = "ssh -i /root/.ssh/id_borg";
    prune.keep.monthly = -1;
    prune.keep.within = "7d";
    repo = "${spire}:borg";
  };

in {
  imports = [
    ./common.nix
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
  ];

  boot.initrd.availableKernelModules =
    [ "ata_piix" "uhci_hcd" "virtio_pci" "sd_mod" "sr_mod" ];

  boot.loader.grub.device = "/dev/sda";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5d9aee32-4ea7-4d3c-92c4-f8497b71113d";
    fsType = "ext4";
  };

  services.nscd.enable = false;
  system.nssModules = lib.mkForce [];
  networking.dhcpcd.enable = false;
  systemd.network.enable = true;
  systemd.network.networks."40-hetzner" = {
    matchConfig.Name = "ens3";
    DHCP = "ipv4";
    address = [ "2a01:4f8:c2c:a8cd::1/64" ];
    gateway = [ "fe80::1" ];
  };

  networking.firewall = {
    interfaces.ens3.allowedTCPPorts = lib.mkForce [
      22 # ssh
      80 # http
      4242 # quassel
    ];

    interfaces.ens3.allowedTCPPortRanges = lib.mkForce [ ];
    interfaces.ens3.allowedUDPPorts = lib.mkForce [
      53 # wireguard
      443 # wireguard
      5353 # wireguard
    ];

    interfaces.ens3.allowedUDPPortRanges = lib.mkForce [ ];
    interfaces.larsnet.allowedTCPPorts = lib.mkForce [
      4242 # quassel
      5432 # postgresql
    ];

    extraCommands = ''
      # Forward port 53 and 443 on the ens3 interface to wireguard
      ip46tables -w -t nat -F PREROUTING
      ip46tables -w -t nat -A PREROUTING -p udp -i ens3 --dport 53 -j REDIRECT --to-ports 5353
      ip46tables -w -t nat -A PREROUTING -p udp -i ens3 --dport 443 -j REDIRECT --to-ports 5353
    '';

    logRefusedConnections = false;
  };

  networking.hostName = "relto";

  networking.nat.enable = true;
  networking.nat.externalInterface = "ens3";
  networking.nat.internalInterfaces = [ "larsnet" ];

  networking.wireguard = {
    enable = true;
    interfaces = {
      "larsnet" = {
        generatePrivateKeyFile = true;
        ips = [ "172.27.0.1/16" ];
        listenPort = 5353;
        privateKeyFile = "/etc/wireguard/larsnet.secret";
        postSetup = "ip link set mtu 1360 dev larsnet";
        peers = [{
          allowedIPs = [ "172.27.0.2" ];
          publicKey = "iJSsDmyHbcFCe9GAtOE40BNUSGy1D6aCjsQUis9wjAU=";
        } {
          allowedIPs = [ "172.27.0.3" ];
          publicKey = "2Mk2D6U06GOogssi0eF8MV125xA4p/6G2kapSH5Ij1U=";
        } {
          allowedIPs = [ "172.27.0.4" ];
          publicKey = "lmL6nSdE3eP3R7KwHi7N4+Iaj2k6Qh9rNWigxYgD8CI=";
        } {
          allowedIPs = [ "172.27.0.5" ];
          publicKey = "kzlM5gXXaI9sl2TTnb14OY+qmFDc4aP89V/ITzcGhj4=";
        } {
          allowedIPs = [ "172.27.0.6" ];
          publicKey = "Nd/H8vMQ/9kB31xWJncZwKmOejLb8qTNbkubhA2N4VA=";
        }];
      };
    };
  };

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 180d";
  nix.settings.cores = 2;
  nix.settings.max-jobs = 2;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.localSystem = lib.systems.examples.gnu64;

  programs.ssh.knownHosts."spire" = {
    extraHostNames = [ "ch-s012.rsync.net" ];
    publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5lfML3qjBiDXi4yh3xPoXPHqIOeLNp66P3Unrl+8g3";
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "acme@u16.nl";

  services.borgbackup.jobs = {
    quassel = common-borg-options // {
      paths = "/tmp/quassel.psql";
      startAt = "*-*-* 05:00:00";
      preHook = ''
        /run/wrappers/bin/sudo -u quassel \
          ${config.services.postgresql.package}/bin/pg_dump > /tmp/quassel.psql
      '';
    };
  };

  services.postgresql = {
    enable = true;
    settings.listen_addresses = lib.mkForce "localhost,172.27.0.1";
    package = pkgs.postgresql_11;
    ensureDatabases = postgresUsers;
    ensureUsers = map (name: {
      inherit name;
      ensurePermissions."DATABASE ${name}" = "ALL PRIVILEGES";
    }) postgresUsers;
    authentication = ''
      host lars,u16 lars 172.27.0.2/32 trust
    '';
  };

  services.quassel = {
    certificateFile = "/var/lib/quassel/quasselCert.pem";
    dataDir = "/var/lib/quassel";
    enable = true;
    interfaces = [ "0.0.0.0" ];
    requireSSL = true;
  };

  systemd.services.postgresql.after = [ "wireguard-larsnet.service" ];

  system.stateVersion = "19.03"; # DO NOT CHANGE
}
