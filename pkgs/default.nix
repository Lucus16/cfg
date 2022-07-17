self: super:

let
  writePythonBin = name: text:
    self.writeTextFile {
      inherit name;
      executable = true;
      destination = "/bin/${name}";
      text = ''
        #!${self.python3}/bin/python
        ${if builtins.isPath text then builtins.readFile text else text}
      '';
    };

in {
  nixos-deploy = self.writeShellScriptBin "nixos-deploy"
    (builtins.readFile ../bin/nixos-deploy);
  next-sink = self.writeShellScriptBin "next-sink"
    (builtins.readFile ../bin/next-sink);
  pwgen = writePythonBin "pwgen" ../bin/pwgen;
  st = import ./st.nix { inherit (super) fetchFromGitHub st; };
  tisdone = self.callPackage ./tisdone.nix { };
}
