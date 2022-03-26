let
  machines = {
    amateria = ./amateria.nix;
    narayan = ./narayan.nix;
    relto = ./relto.nix;
  };

  nixos = import ../nixpkgs/nixos;

  machine = name: configuration: nixos { inherit configuration; };

in builtins.mapAttrs machine machines
