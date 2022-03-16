{ config, lib, pkgs, ... }:

{
  imports = [ ../nixos-m1/nix/m1-support ./common.nix ];

  # Does not work yet
  #boot.binfmt.emulatedSystems = [ "x86_64-linux" ];

  boot.initrd.availableKernelModules = [ "usb_storage" ];
  boot.kernelBuildIsCross = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  fileSystems."/" = {
    device = "/dev/disk/by-label/narayan";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7A1D-1702";
    fsType = "vfat";
  };

  hardware.enableRedistributableFirmware = false;

  networking.dhcpcd.extraConfig = "noarp"; # Speed up DHCP from 5s to 1s.
  networking.hostName = "narayan";
  networking.nameservers = [ "1.1.1.1" ];
  networking.networkmanager.enable = lib.mkForce false;
  networking.wireless.enable = true;

  networking.useDHCP = false;
  networking.interfaces.wlp1s0f0.useDHCP = true;

  networking.wireguard = {
    enable = true;
    interfaces = {
      larsnet = {
        generatePrivateKeyFile = true;
        ips = [ "172.27.0.6" ];
        privateKeyFile = "/etc/wireguard/larsnet.secret";
        postSetup = "ip link set mtu 1360 dev larsnet";
        peers = [{
          allowedIPs = [ "172.27.0.0/16" ];
          endpoint = "4.u16.nl:5353";
          persistentKeepalive = 24;
          publicKey = "d1JVe9OQEwocZjuYCr4uVlTV9lURCaGklf/nYYsC204=";
        }];
      };
    };
  };

  nix.buildMachines = [
    {
      hostName = "amateria";
      system = "x86_64-linux";
      maxJobs = 16;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }
  ];

  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;
  nix.settings.cores = 8;
  nix.settings.max-jobs = 8;
  nix.settings.trusted-users = [ "lars" "root" ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.localSystem = lib.systems.examples.aarch64-multiplatform;

  powerManagement.cpuFreqGovernor = "ondemand";

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.slock.enable = true;

  # YubiKey
  services.pcscd.enable = true;

  services.unclutter-xfixes.enable = true;

  services.xserver = {
    autoRepeatDelay = 250;
    autoRepeatInterval = 25;
    displayManager.gdm.enable = true;
    dpi = 144;
    enable = true;
    libinput.enable = true;
    libinput.touchpad.accelSpeed = "0.3";
    libinput.touchpad.buttonMapping = "1 3 2";
    libinput.touchpad.disableWhileTyping = true;
    libinput.touchpad.naturalScrolling = true;
    libinput.touchpad.tapping = false;
    windowManager.i3.enable = true;
    xkbOptions = "caps:escape";
    xautolock = {
      enable = true;
      locker = "/run/wrappers/bin/slock";
      time = 10; # minutes
    };
  };

  systemd.user.services.libinput-gestures = let
    i3 = config.services.xserver.windowManager.i3.package;
    configFile = pkgs.writeText "libinput-gestures.conf" ''
      gesture swipe left  ${i3}/bin/i3-msg workspace next
      gesture swipe right ${i3}/bin/i3-msg workspace prev
    '';
  in {
    description = "Touchpad gestures";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig.ExecStart = ''
      ${pkgs.libinput-gestures}/bin/libinput-gestures -c ${configFile}
    '';
  };

  users.users.lars.extraGroups = [ "input" ];

  system.stateVersion = "22.05";
}