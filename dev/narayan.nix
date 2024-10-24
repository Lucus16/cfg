{ config, lib, pkgs, ... }:

{
  imports = [ ../nixos-apple-silicon/apple-silicon-support ./common.nix ];

  boot.initrd.availableKernelModules = [ "usb_storage" ];
  boot.loader.efi.canTouchEfiVariables = false;

  fileSystems."/" = {
    device = "/dev/disk/by-label/narayan";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7A1D-1702";
    fsType = "vfat";
  };

  hardware.asahi.useExperimentalGPUDriver = true;

  hardware.bluetooth.enable = true;
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
          endpoint = "4.u16.nl:30567";
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

  programs.evolution.enable = true;
  programs.geary.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.slock.enable = true;

  programs.xss-lock.enable = true;
  programs.xss-lock.lockerCommand = "/run/wrappers/bin/slock";

  services.libinput = {
    enable = true;
    touchpad.accelSpeed = "0.3";
    touchpad.buttonMapping = "1 3 2";
    touchpad.disableWhileTyping = true;
    touchpad.naturalScrolling = true;
    touchpad.tapping = false;
  };

  # YubiKey
  services.pcscd.enable = true;

  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.jack.enable = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.wireplumber.enable = true;

  services.udev.extraRules = lib.concatStringsSep "\n"
    (map (lib.concatStringsSep ", ") [
      [ # Don't charge battery past 80% in order to extend battery life.
        ''SUBSYSTEM=="power_supply"''
        ''KERNEL=="macsmc-battery"''
        ''ATTR{charge_control_end_threshold}="80"''
        ''ATTR{charge_control_start_threshold}="70"''
      ]
    ]);

  services.unclutter-xfixes.enable = true;

  services.xserver = {
    autoRepeatDelay = 250;
    autoRepeatInterval = 25;
    dpi = 144;
    enable = true;
    windowManager.i3.enable = true;
    xkb.options = "caps:escape";
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
