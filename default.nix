import ./nixpkgs {
  overlays = [
    (import ./pkgs)
    (import ./dev)
  ];
}
