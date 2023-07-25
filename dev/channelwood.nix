{ config, pkgs, lib, ... }:

{
  imports = [ ./common.nix ./lumiguide.nix ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" ];

  boot.initrd.luks.devices.cryptroot = {
    allowDiscards = true;
    device = "/dev/disk/by-uuid/9501ab20-be81-423f-a147-18cbfc81614b";
    fallbackToPassword = true;
    keyFile = "/crypto_keyfile.bin";
  };

  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = "/etc/secrets/initrd/crypto_keyfile.bin";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.enableCryptodisk = true;

  # https://bugzilla.kernel.org/show_bug.cgi?id=196729
  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.min_free_kbytes" = 196608;
    "watermark_scale_factor" = 200;
  };

  boot.kernelModules = [ "kvm-intel" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/edc1e1b2-1aa8-4da0-9f50-84e67ca6a835";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/E0A0-F4CF";
    fsType = "vfat";
  };

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.pulseaudio.enable = true;

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod.enabled = "fcitx";
    inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
  };

  networking.dhcpcd.extraConfig = "noarp";
  networking.hostName = "channelwood";
  networking.nameservers = [ "1.1.1.1" ];
  networking.wireless.enable = true;
  networking.wireless.interfaces = [ "wlp3s0" ];

  networking.wireguard = {
    enable = true;
    interfaces = {
      larsnet = {
        generatePrivateKeyFile = true;
        ips = [ "172.27.0.2" ];
        privateKeyFile = "/etc/wireguard/larsnet.secret";
        postSetup = "ip link set mtu 1360 dev larsnet";
        peers = [{
          #allowedIPs = [ "0.0.0.0/0" "::/0" ];
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
      speedFactor = 8;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }
  ];

  nix.buildCores = 4;
  nix.distributedBuilds = true;
  nix.maxJobs = 4;
  nix.trustedUsers = [ "root" "lars" ];
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  nixpkgs.config.allowUnfree = true;

  powerManagement.cpuFreqGovernor = "powersave";

  # Reduce fan noise by lowering performance.
  powerManagement.powerUpCommands = ''
    echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo
  '';

  programs.adb.enable = true;
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;
  programs.slock.enable = true;

  services.compton = {
    enable = true;
    backend = "glx";
    vSync = true;
  };

  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';

  services.pcscd.enable = true;

  services.udev.extraRules = lib.concatStringsSep "\n"
    (map (lib.concatStringsSep ", ") [
      [ # backlight
        ''ACTION=="add"''
        ''SUBSYSTEM=="backlight"''
        ''KERNEL=="intel_backlight"''
        ''RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"''
      ]
    ]);

  services.unclutter-xfixes.enable = true;

  services.xserver = {
    dpi = 144;
    enable = true;
    synaptics.accelFactor = "0.05";
    synaptics.enable = true;
    synaptics.scrollDelta = -75;
    synaptics.twoFingerScroll = true;
    videoDrivers = [ "modesetting" ];
    wacom.enable = true;
    windowManager.i3.enable = true;
    xautolock.enable = true;
    xautolock.locker = "/run/wrappers/bin/slock";
    xautolock.time = 10; # minutes
  };

  sound.enable = true;

  swapDevices =
    [{ device = "/dev/disk/by-uuid/c44de2ce-3f0c-4f87-8db6-5afb7f265ff7"; }];

  systemd.services.power_usage = {
    script = ''
      echo $(cat /sys/class/power_supply/BAT0/energy_now) \
           $(cat /sys/class/backlight/intel_backlight/brightness)
    '';
    serviceConfig.Type = "oneshot";
  };

  systemd.timers.power_usage = {
    timerConfig.OnCalendar = "minutely";
    wantedBy = [ "timers.target" ];
  };

  users.users.lars.extraGroups = [ "audio" ];

  system.stateVersion = "19.03"; # DO NOT CHANGE
}
