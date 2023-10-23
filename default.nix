{ lib
, stdenv
, hyprland
,
}:
stdenv.mkDerivation {
  pname = "hycov";
  version = "0.1";
  src = ./.;

  inherit (hyprland) nativeBuildInputs;

  buildInputs = [ hyprland ] ++ hyprland.buildInputs;
}
