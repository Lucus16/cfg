{ fetchFromGitHub, st }:

(st.overrideAttrs (o: {
  src = fetchFromGitHub {
    owner = "Lucus16";
    repo = "st";
    rev = "master";
    sha256 = "0xwz9bi3v1ww82bf12vl0fr2dz8synnjiabc166zra0jhhg4f1b7";
  };
}))
