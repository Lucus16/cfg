{ fetchFromGitHub, st }:

(st.overrideAttrs (o: {
  src = fetchFromGitHub {
    owner = "Lucus16";
    repo = "st";
    rev = "master";
    sha256 = "sha256-9AFPMFs5c+3R3qTBhdrkvioHNWuXpFqNYqjUTUunOhE=";
  };
}))
