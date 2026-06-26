{ fetchFromGitHub, st }:

(st.overrideAttrs (o: {
  src = fetchFromGitHub {
    owner = "Lucus16";
    repo = "st";
    rev = "master";
    sha256 = "sha256-YLBFZUirjdPO5sivzrj4QBQfx7I4sb8C2LKnRF1ukf8=";
  };
}))
