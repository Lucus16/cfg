self: super:

{
  st = import ./st.nix { inherit (super) fetchFromGitHub st; };
  tisdone = self.callPackage ./tisdone.nix { };
  nixos-deploy = self.callPackage ./nixos-deploy.nix { };
}
