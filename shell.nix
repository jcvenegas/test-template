let
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  nixpkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };
  #rustNightlyChannel = (nixpkgs.rustChannelOf { date = "2019-01-26"; channel = "nightly"; }).rust;
  rustStableChannel = nixpkgs.latest.rustChannels.stable.rust.override {
    extensions = [
      "rust-src"
      "clippy-preview"
    ];
  };
in
  with nixpkgs;
  stdenv.mkDerivation {
    name = "moz_overlay_shell";
    shellHook = ''
      export OPENSSL_DIR="${pkgs.openssl.dev}"
      export OPENSSL_LIB_DIR="${pkgs.openssl.out}/lib"
   '';
    buildInputs = [
      rustStableChannel
      rustup
    ];
  }

