self: super:

let
  inherit (super) lib;
  eval-config = import ../nixpkgs/nixos/lib/eval-config.nix;
  eval-module = config: eval-config { modules = [ config ]; };

  configs = lib.mapAttrs (name: eval-module) {
    relto = import ./relto.nix;
  };

  systems = lib.mapAttrs (name: config: config.config.system.build.toplevel) configs;

in {
  larsnet = {
    inherit configs systems;
  } // systems;
}
