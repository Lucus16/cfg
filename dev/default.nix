let
  machines = {
    amateria = ./amateria.nix;
    relto = ./relto.nix;
  };

  nixos = import ../nixpkgs/nixos;

  machine = name: configuration: nixos { inherit configuration; };

in builtins.mapAttrs machine machines
