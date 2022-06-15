{ pkgs, ... }:

{
  boot.cleanTmpDir = true;

  environment.systemPackages = with pkgs; [
    gitMinimal
    htop
    man-pages
    neovim
    ripgrep
  ];

  nixpkgs.overlays = [ (import ../pkgs) ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
  };

  services.xserver.displayManager.job.logToJournal = false;

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
