{ fetchFromGitHub, st }:

(st.overrideAttrs (o: {
  src = fetchFromGitHub {
    owner = "Lucus16";
    repo = "st";
    rev = "master";
    sha256 = "sha256-PV6UeKuFm98vwsspIRGcLQcHpQsTIBf3pFETREFtyWY=";
  };
}))
