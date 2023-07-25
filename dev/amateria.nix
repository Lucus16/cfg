{ config, lib, pkgs, ... }:

{
  imports = [ ./common.nix ./lumiguide.nix ];

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "armv6l-linux"
    "armv7l-linux"
  ];

  # Needed for virtual machine nixos tests.
  boot.extraModprobeConfig = "options kvm-amd nested=1";

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];

  # https://bugzilla.kernel.org/show_bug.cgi?id=196729
  #boot.kernel.sysctl = {
  #  "vm.swappiness" = 100;
  #  "vm.min_free_kbytes" = 196608;
  #  "watermark_scale_factor" = 200;
  #};

  boot.kernelModules = [ "kvm-amd" "nct6775" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;

  environment.etc."X11/xorg.conf.d/71-wacom-options.conf".text = ''
    Section "InputClass"
      Identifier "WACOM OPTIONS pen"
      MatchDriver "wacom"
      MatchProduct "Pen"
      NoMatchProduct "eraser"
      NoMatchProduct "cursor"
      Option "BottomX" "7680"
      Option "BottomY" "4320"
    EndSection
  '';

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b674a178-f90e-422b-bb42-13a2f4da3b8b";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/83C5-DA38";
    fsType = "vfat";
  };

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # Vulkan and steam support
  hardware = {
    opengl.enable = true;
    opengl.driSupport = true;
    opengl.driSupport32Bit = true;
    pulseaudio.support32Bit = true;
  };

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.extraConfig = ''
    unload-module module-suspend-on-idle
  '';

  networking.dhcpcd.extraConfig = "noarp"; # Speed up DHCP from 5s to 1s.
  networking.hostName = "amateria";
  networking.interfaces.enp5s0.useDHCP = true;
  networking.nameservers = [ "1.1.1.1" ];
  networking.useDHCP = false;

  networking.firewall = {
    interfaces.enp5s0.allowedTCPPorts = lib.mkForce [
      22 # ssh
    ];
  };

  networking.wireguard = {
    enable = true;
    interfaces = {
      larsnet = {
        generatePrivateKeyFile = true;
        ips = [ "172.27.0.4" ];
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

  nix.settings.cores = 16;
  nix.settings.max-jobs = 16;
  nix.settings.secret-key-files = "/etc/secrets/cache-privkey.pem";
  nix.settings.trusted-users = [ "lars" "root" ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.localSystem = lib.systems.examples.gnu64;

  powerManagement.cpuFreqGovernor = "ondemand";

  programs.adb.enable = true;
  programs.corectrl.enable = true;
  programs.geary.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.slock.enable = true;

  sound.mediaKeys.enable = true;

  # YubiKey
  services.pcscd.enable = true;

  services.picom.enable = true;
  services.picom.vSync = true;

  services.udev.extraRules = lib.concatStringsSep "\n"
    (map (lib.concatStringsSep ", ") [
      [ # EdgeTPU
        ''ATTRS{idVendor}=="1a6e"''
        ''ATTRS{idProduct}=="089a"''
        ''GROUP="dialout"''
      ]
      [ # EdgeTPU
        ''ATTRS{idVendor}=="18d1"''
        ''ATTRS{idProduct}=="9302"''
        ''GROUP="dialout"''
      ]
    ]);

  services.unclutter-xfixes.enable = true;

  services.xserver = {
    dpi = 144;
    enable = true;
    videoDrivers = [ "modesetting" ];
    wacom.enable = true;
    windowManager.i3.enable = true;
    xautolock = {
      enable = true;
      locker = "/run/wrappers/bin/slock";
      time = 10; # minutes
    };
  };

  sound.enable = true;

  systemd.coredump.extraConfig = ''
    ProcessSizeMax=16G
    ExternalSizeMax=16G
  '';

  users.users.lars.extraGroups = [ "audio" "dialout" "wheel" ];

  users.users.lucus = {
    extraGroups = [ "audio" ];
    isNormalUser = true;
  };

  system.stateVersion = "19.09"; # DO NOT CHANGE
}
