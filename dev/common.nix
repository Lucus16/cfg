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

  #nix.nixPath = [ "nixpkgs=${../nixpkgs}" ];
  nix.package = pkgs.nix_2_3;

  nixpkgs.overlays = [ (import ../pkgs) ];
  nixpkgs.pkgs = import ../nixpkgs { };

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
