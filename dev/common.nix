{ pkgs, ... }:

{
  boot.tmp.cleanOnBoot = true;

  environment.systemPackages = with pkgs; [
    gitMinimal
    htop
    man-pages
    ncdu
    neovim
    ripgrep
  ];

  nix.settings.experimental-features = "flakes nix-command";

  nixpkgs.overlays = [ (import ../pkgs) ];

  services.displayManager.logToJournal = false;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
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
