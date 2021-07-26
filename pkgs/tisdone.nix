{ alsa-utils, writeShellScriptBin }:

writeShellScriptBin "tisdone" ''
  if "$@"; then
    ${alsa-utils}/bin/aplay -q ${../res/ok.wav} 2>/dev/null & exit 0
  else
    rv=$?
    ${alsa-utils}/bin/aplay -q ${../res/error.wav} 2>/dev/null & exit $rv
  fi
''
