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

  meta = with lib; {
    homepage = "https://github.com/DreamMaoMao/hycov";
    description = "clients overview for hyprland plugin";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
