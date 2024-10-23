{ fetchFromGitHub, st }:

(st.overrideAttrs (o: {
  src = fetchFromGitHub {
    owner = "Lucus16";
    repo = "st";
    rev = "master";
    sha256 = "sha256-6iHbIAr2FA7sF7qsjC/Q/Dsm/PXvpqb2VO4yxUh85Dc=";
  };
}))
