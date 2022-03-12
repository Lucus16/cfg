{ writeShellScriptBin }:

writeShellScriptBin "nixos-deploy" (builtins.readFile ../bin/nixos-deploy)
