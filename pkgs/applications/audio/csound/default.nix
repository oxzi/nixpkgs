{ lib, stdenv, fetchFromGitHub, cmake, libsndfile, libsamplerate, flex, bison, boost, gettext
, alsa-lib ? null
, libpulseaudio ? null
, libjack2 ? null
, liblo ? null
, ladspa-sdk ? null
, fluidsynth ? null
# , gmm ? null  # opcodes don't build with gmm 5.1
, eigen ? null
, curl ? null
, tcltk ? null
, fltk ? null
}:

stdenv.mkDerivation rec {
  pname = "csound";
  # When updating, please check if https://github.com/csound/csound/issues/1078
  # has been fixed in the new version so we can use the normal fluidsynth
  # version and remove fluidsynth 1.x from nixpkgs again.
  version = "6.16.0";

  hardeningDisable = [ "format" ];

  src = fetchFromGitHub {
    owner = "csound";
    repo = "csound";
    rev = version;
    sha256 = "sha256-1+P2W8auc34sNJdKHUcilOBCK+Is9GHnM+J+M4oNR3U=";
  };

  cmakeFlags = [ "-DBUILD_CSOUND_AC=0" ] # fails to find Score.hpp
    ++ lib.optional (libjack2 != null) "-DJACK_HEADER=${libjack2}/include/jack/jack.h";

  nativeBuildInputs = [ cmake flex bison gettext ];
  buildInputs = [ libsndfile libsamplerate boost ]
    ++ builtins.filter (optional: optional != null) [
      alsa-lib libpulseaudio libjack2
      liblo ladspa-sdk fluidsynth eigen
      curl tcltk fltk ];

  meta = with lib; {
    description = "Sound design, audio synthesis, and signal processing system, providing facilities for music composition and performance on all major operating systems and platforms";
    homepage = "http://www.csounds.com/";
    license = licenses.gpl2;
    maintainers = [maintainers.marcweber];
    platforms = platforms.linux;
  };
}

