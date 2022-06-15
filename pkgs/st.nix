{ fetchFromGitHub, st }:

(st.overrideAttrs (o: {
  src = fetchFromGitHub {
    owner = "Lucus16";
    repo = "st";
    rev = "master";
    sha256 = "1lnxx99b9r01f8fc7qg44bvk0k9rrb97yx7dkys58m5ss9ax6jv4";
  };
}))
