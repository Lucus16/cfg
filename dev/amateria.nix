{ lib, pkgs, ... }:

{
  imports = [ ./common.nix ./lumiguide.nix ];

  boot.binfmt.emulatedSystems =
    [ "aarch64-linux" "armv6l-linux" "armv7l-linux" ];

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

  boot.supportedFilesystems = [ "ntfs" ];

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

  environment.systemPackages = with pkgs; [
    discord
    feh
    firefox
    mpv
    mupdf
    nixfmt-classic
    noto-fonts
    noto-fonts-cjk-sans
    obsidian
    pass
    prismlauncher
    redshift
    st
    telegram-desktop
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b674a178-f90e-422b-bb42-13a2f4da3b8b";
    fsType = "ext4";
  };

  fileSystems."/games" = {
    device = "/dev/disk/by-uuid/bceb000c-8052-48be-bcb8-f4cac557d2c5";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  fileSystems."/big" = {
    device = "/dev/disk/by-uuid/9f71a541-36e5-4884-b7de-b44453b3c780";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/83C5-DA38";
    fsType = "vfat";
  };

  hardware.amdgpu.opencl.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  location.latitude = 52.0;
  location.longitude = 6.0;

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
          endpoint = "4.u16.nl:30567";
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
  programs.evolution.enable = true;
  programs.geary.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.slock.enable = true;

  programs.steam.enable = true;
  programs.steam.extraCompatPackages = with pkgs; [ proton-ge-bin ];
  programs.steam.gamescopeSession.enable = true;
  programs.steam.protontricks.enable = true;

  services.actkbd = {
    enable = true;
    bindings = [
      { # "Mute" media key
        keys = [ 113 ];
        events = [ "key" ];
        command = "${pkgs.alsa-utils}/bin/amixer -q set Master toggle";
      }
      { # "Lower Volume" media key
        keys = [ 114 ];
        events = [ "key" "rep" ];
        command =
          "${pkgs.alsa-utils}/bin/amixer -q set Master 1%- unmute";
      }
      { # "Raise Volume" media key
        keys = [ 115 ];
        events = [ "key" "rep" ];
        command =
          "${pkgs.alsa-utils}/bin/amixer -q set Master 1%+ unmute";
      }
      { # "Mic Mute" media key
        keys = [ 190 ];
        events = [ "key" ];
        command = "${pkgs.alsa-utils}/bin/amixer -q set Capture toggle";
      }
    ];
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    rocmOverrideGfx = "11.0.0";
  };

  # YubiKey
  services.pcscd.enable = true;

  services.picom.enable = true;
  services.picom.vSync = true;

  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.jack.enable = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.wireplumber.enable = true;
  services.pipewire.wireplumber.extraConfig = {
    "no-popping"."monitor.alsa.rules" = [
      {
        matches = [
          { "node.name" = "~alsa_input.*"; }
          { "node.name" = "~alsa_output.*"; }
        ];
        actions.update-props = {
          "node.pause-on-idle" = false;
          "session.suspend-timeout-seconds" = 0;
        };
      }
    ];
  };

  services.redshift = {
    enable = true;
    temperature.day = 6500;
    temperature.night = 1000;
    extraOptions = [
      "-P"
      "-c${pkgs.writeText "redshift.conf" ''
        [redshift]
        dawn-time=06:00-08:00
        dusk-time=21:00-23:00
      ''}"
    ];
  };

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
    videoDrivers = [ "amdgpu" "modesetting" ];
    wacom.enable = true;
    windowManager.i3.enable = true;
  };

  systemd.coredump.extraConfig = ''
    ProcessSizeMax=16G
    ExternalSizeMax=16G
  '';

  users.users.lars.extraGroups =
    [ "adbusers" "audio" "corectrl" "dialout" "kvm" "wheel" ];

  users.users.lucus = {
    extraGroups = [ "audio" "corectrl" ];
    isNormalUser = true;
  };

  system.stateVersion = "19.09"; # DO NOT CHANGE
}
