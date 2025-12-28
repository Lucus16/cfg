{ pkgs, ... }:

{
  boot.tmp.cleanOnBoot = true;

  environment.systemPackages = with pkgs; [
    gitMinimal
    file
    htop
    man-pages
    ncdu
    neovim
    ripgrep
  ];

  nix.settings.experimental-features = "flakes nix-command";

  nixpkgs.overlays = [ (import ../pkgs) ];

  programs.ssh.knownHosts.spire = {
    extraHostNames = [ "zh6185.rsync.net" ];
    publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJtclizeBy1Uo3D86HpgD3LONGVH0CJ0NT+YfZlldAJd";
  };

  services.displayManager.logToJournal = false;

  services.openssh = {
    enable = true;
    settings.KbdInteractiveAuthentication = false;
    settings.LogLevel = "ERROR";
    settings.PasswordAuthentication = false;
  };

  services.xserver = {
    autoRepeatDelay = 250;
    autoRepeatInterval = 25;
    xkb.options = "caps:escape";
  };

  time.timeZone = "Europe/Amsterdam";

  users.users = {
    lars = {
      extraGroups = [ "wheel" ];
      isNormalUser = true;
      openssh.authorizedKeys.keyFiles = [ ../dot/ssh/.ssh/authorized_keys ];
    };

    root = {
      openssh.authorizedKeys.keyFiles = [ ../dot/ssh/.ssh/authorized_keys ];
    };
  };
}
