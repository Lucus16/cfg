let
  sources = import nix/sources.nix;

in import ./nixpkgs {
  overlays = [
    (import ./pkgs)
    (import "${sources.nix-minecraft}/overlay.nix")
  ];
}
