{ stdenv, pkgs, hugo }:

let hugoTheme = pkgs.fetchFromGitHub {
  owner = "adityatelange";
  repo = "hugo-PaperMod";
  rev = "master";
  hash = "sha256-757KZeSoDjubnd0eYTNkclfItg5Q+HGi89ZWtA7zg8U=";
};
in
stdenv.mkDerivation {
  name = "hugo-christopherjones-us";
  src = pkgs.fetchFromGitHub {
    owner = "magikid";
    repo = "website";
    rev = "master";
    hash = "sha256-SBiTs6+zZJRGFT1MQh95y83YYiFBqIFy/uTgilQOXDA=";
  };
  nativeBuildInputs = [ hugo ];
  phases = [ "unpackPhase" "buildPhase" ];
  buildPhase = ''
    mkdir -p "$out/themes/PaperMod"
    cp -r ${hugoTheme}/* "$out/themes/PaperMod/"

    mkdir -p "./themes/PaperMod"
    cp -r ${hugoTheme}/* "./themes/PaperMod/"

    hugo --theme PaperMod --config ./config.toml --gc --minify --cleanDestinationDir --environment production --source . --destination "$out"
  '';
}
