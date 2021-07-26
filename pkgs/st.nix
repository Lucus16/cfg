{ fetchFromGitHub, st }:

(st.overrideAttrs (o: {
  src = fetchFromGitHub {
    owner = "Lucus16";
    repo = "st";
    rev = "master";
    sha256 = "1g0364lngp1nsxg4wb1wwfzp6wlfc2xcw17cb9k2y4izsb69fkd4";
  };
}))
