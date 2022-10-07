{ alsa-utils, writeShellScriptBin }:

writeShellScriptBin "tisdone" ''
  if "$@"; then
    ${alsa-utils}/bin/aplay ${../res/ok.wav} >/dev/null 2>/dev/null & exit 0
  else
    rv=$?
    ${alsa-utils}/bin/aplay ${../res/error.wav} >/dev/null 2>/dev/null & exit $rv
  fi
''
