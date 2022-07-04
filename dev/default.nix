let
  machines = {
    amateria = ./amateria.nix;
    channelwood = ./channelwood.nix;
    narayan = ./narayan.nix;
    relto = ./relto.nix;
  };

  nixos = import ../nixpkgs/nixos;

  machine = name: configuration: nixos { inherit configuration; };

in builtins.mapAttrs machine machines
