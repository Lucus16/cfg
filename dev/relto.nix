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

  simple-nixos-mailserver = builtins.fetchTarball {
    url =
      "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/008d78cc21959e33d0d31f375b88353a7d7121ae/nixos-mailserver-008d78cc21959e33d0d31f375b88353a7d7121ae.tar.gz";
    sha256 = "0pnfyg4icsvrw390a227m8b1j5w8awicx5aza3d0fiyyzpnrpn5a";
  };

in {
  imports = [
    ./common.nix
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    simple-nixos-mailserver
  ];

  boot.initrd.availableKernelModules =
    [ "ata_piix" "uhci_hcd" "virtio_pci" "sd_mod" "sr_mod" ];

  boot.loader.grub.device = "/dev/sda";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5d9aee32-4ea7-4d3c-92c4-f8497b71113d";
    fsType = "ext4";
  };

  # Unfortunately, scripted networking can't use DHCP only for IPv4.
  networking.useDHCP = false;
  services.resolved.enable = false;
  systemd.network.enable = true;
  systemd.network.networks."40-hetzner" = {
    matchConfig.Name = "ens3";
    DHCP = "ipv4";
    address = [ "2a01:4f8:c2c:a8cd::1/64" ];
    gateway = [ "fe80::1" ];
  };

  documentation.nixos.enable = false;

  mailserver = {
    enable = true;
    certificateDomains = [ "imap.u16.nl" "mail.u16.nl" "smtp.u16.nl" ];
    certificateScheme = "acme-nginx";
    fqdn = "relto.u16.nl";
    domains = [ "u16.nl" ];
    loginAccounts."lars@u16.nl" = {
      hashedPassword =
        "$2y$05$KEryliesLyehI7i2dJudNOfYuX3UjUkrxv5WaDd96Q8XFAbwMqQHC";
      catchAll = [ "u16.nl" ]; # Receive from all addresses
      aliases = [ "@u16.nl" ]; # Send from all addresses
    };
    fullTextSearch.enable = true;
  };

  networking.firewall = {
    interfaces.ens3.allowedTCPPorts = lib.mkForce [
      22 # ssh
      25 # smtp
      80 # http
      143 # imap starttls
      443 # https
      465 # smtp tls
      587 # smtp starttls
      993 # imap tls
      4242 # quassel
    ];

    interfaces.ens3.allowedTCPPortRanges = lib.mkForce [ ];
    interfaces.ens3.allowedUDPPorts = lib.mkForce [
      30567 # wireguard
    ];

    interfaces.ens3.allowedUDPPortRanges = lib.mkForce [ ];
    interfaces.larsnet.allowedTCPPorts = lib.mkForce [
      4242 # quassel
      5432 # postgresql
    ];

    logRefusedConnections = false;
  };

  networking.hostName = "relto";

  networking.nat.enable = true;
  networking.nat.externalInterface = "ens3";
  networking.nat.internalInterfaces = [ "larsnet" ];

  networking.wireguard = {
    enable = true;
    interfaces.larsnet = {
      generatePrivateKeyFile = true;
      ips = [ "172.27.0.1/16" ];
      listenPort = 30567;
      privateKeyFile = "/etc/wireguard/larsnet.secret";
      postSetup = "ip link set mtu 1360 dev larsnet";
      peers = lib.attrValues {
        nokia6.allowedIPs = [ "172.27.0.2" ];
        nokia6.publicKey = "LQI1iPdhSk5QxrTsL+2ZLRICz9wD4qIJZjrfc7w4NkE=";
        amateria.allowedIPs = [ "172.27.0.4" ];
        amateria.publicKey = "lmL6nSdE3eP3R7KwHi7N4+Iaj2k6Qh9rNWigxYgD8CI=";
        edanna.allowedIPs = [ "172.27.0.5" ];
        edanna.publicKey = "kzlM5gXXaI9sl2TTnb14OY+qmFDc4aP89V/ITzcGhj4=";
        narayan.allowedIPs = [ "172.27.0.6" ];
        narayan.publicKey = "Nd/H8vMQ/9kB31xWJncZwKmOejLb8qTNbkubhA2N4VA=";
      };
    };
  };

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 180d";
  nix.settings.cores = 2;
  nix.settings.max-jobs = 2;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.localSystem = lib.systems.examples.gnu64;

  programs.ssh.knownHosts.spire = {
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

    mail = common-borg-options // {
      paths = "/var/vmail";
      startAt = "*-*-* 04:00:00";
    };
  };

  services.postgresql = {
    enable = true;
    settings.listen_addresses = lib.mkForce "localhost,172.27.0.1";
    package = pkgs.postgresql_16;
    ensureDatabases = postgresUsers;
    ensureUsers = map (name: {
      inherit name;
      ensureDBOwnership = true;
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
