{ config, pkgs, lib, ... }:

let
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
    device = "/dev/disk/by-uuid/c7481c8c-53d8-4f96-ae2e-5469dbe8dae4";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/93d0da48-9e6d-4559-a339-2c78e5c9e4fc";
    fsType = "ext4";
  };

  # Unfortunately, scripted networking can't use DHCP only for IPv4.
  networking.useDHCP = false;
  networking.usePredictableInterfaceNames = false;
  services.resolved.enable = false;
  systemd.network.enable = true;
  systemd.network.networks."40-hetzner" = {
    matchConfig.Name = "eth0";
    DHCP = "ipv4";
    address = [ "2a01:4f8:1c1f:bf0b::1/64" ];
    gateway = [ "fe80::1" ];
  };

  documentation.nixos.enable = false;

  networking.firewall = {
    interfaces.eth0.allowedTCPPortRanges = lib.mkForce [ ];
    interfaces.eth0.allowedTCPPorts = lib.mkForce [
      22 # ssh
      25565 # minecraft
    ];

    interfaces.eth0.allowedUDPPortRanges = lib.mkForce [ ];
    interfaces.eth0.allowedUDPPorts = lib.mkForce [
      25565 # minecraft
    ];

    logRefusedConnections = false;
  };

  networking.hostName = "serenia";

  networking.nameservers = [
    "185.12.64.1"
    "185.12.64.2"
    "2a01:4ff:ff00::add:1"
    "2a01:4ff:ff00::add:2"
  ];

  networking.wireguard = {
    enable = true;
    interfaces = {
      larsnet = {
        generatePrivateKeyFile = true;
        ips = [ "172.27.0.7" ];
        privateKeyFile = "/etc/wireguard/larsnet.secret";
        postSetup = "ip link set mtu 1360 dev larsnet";
        peers = [{
          allowedIPs = [ "172.27.0.0/16" ];
          endpoint = "4.u16.nl:30567";
          persistentKeepalive = 24;
          publicKey = "d1JVe9OQEwocZjuYCr4uVlTV9lURCaGklf/nYYsC204=";
        }];
      };
    };
  };

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 180d";
  nix.settings.cores = 4;
  nix.settings.max-jobs = 4;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.localSystem = lib.systems.examples.gnu64;
  nixpkgs.overlays =
    let sources = import ../nix/sources.nix;
    in [
      (import "${sources.nix-minecraft}/overlay.nix")
    ];

  programs.ssh.knownHosts.spire = {
    extraHostNames = [ "ch-s012.rsync.net" ];
    publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5lfML3qjBiDXi4yh3xPoXPHqIOeLNp66P3Unrl+8g3";
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "acme@u16.nl";

  services.borgbackup.jobs = {
    minecraft = common-borg-options // {
      # TODO: World only, excluding distant horizons data
      # TODO: wait for saving done message in journalctl with timeout
      paths = config.services.minecraft-server.dataDir;
      startAt = "*-*-* 05:30:00";
      preHook = ''
        echo /save-off > /run/minecraft-server.stdin
        echo /save-all > /run/minecraft-server.stdin
        sleep 300
      '';
      postHook = ''
        echo /save-on > /run/minecraft-server.stdin
      '';
    };
  };

  services.minecraft-server = {
    enable = true;
    package = pkgs.minecraftServers.fabric-1_21_11;
    eula = true;
    jvmOpts = "-Xmx24G -Xms24G";
  };

  system.stateVersion = "19.03"; # DO NOT CHANGE
}
