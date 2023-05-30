{ stdenv, lib, callPackage, fetchurl, dart }:
let
  mkFlutter = opts: callPackage (import ./flutter.nix opts) { };
  getPatches = dir:
    let files = builtins.attrNames (builtins.readDir dir);
    in map (f: dir + ("/" + f)) files;
  flutterDrv = { version, pname, dartVersion, flutterHash, dartHash, patches }: mkFlutter {
    inherit version pname patches;
    dart = dart.override {
      version = dartVersion;
      sources = {
        "${dartVersion}-x86_64-linux" = fetchurl {
          url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${dartVersion}/sdk/dartsdk-linux-x64-release.zip";
          sha256 = dartHash.x86_64-linux;
        };
        "${dartVersion}-aarch64-linux" = fetchurl {
          url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${dartVersion}/sdk/dartsdk-linux-arm64-release.zip";
          sha256 = dartHash.aarch64-linux;
        };
        "${dartVersion}-x86_64-darwin" = fetchurl {
          url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${dartVersion}/sdk/dartsdk-macos-x64-release.zip";
          sha256 = dartHash.x86_64-darwin;
        };
        "${dartVersion}-aarch64-darwin" = fetchurl {
          url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${dartVersion}/sdk/dartsdk-macos-arm64-release.zip";
          sha256 = dartHash.aarch64-darwin;
        };
      };
    };
    src = rec {
      x86_64-linux = fetchurl {
        url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${version}-stable.tar.xz";
        sha256 = flutterHash.x86_64-linux;
      };
      aarch64-linux = fetchurl {
        url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${version}-stable.tar.xz";
        sha256 = flutterHash.aarch64-linux;
      };
      x86_64-darwin = fetchurl {
        url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_${version}-stable.zip";
        sha256 = flutterHash.x86_64-darwin;
      };
      aarch64-darwin = fetchurl {
        url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_${version}-stable.zip";
        sha256 = flutterHash.aarch64-darwin;
      };
    }.${stdenv.hostPlatform.system};
  };
  flutter2Patches = getPatches ./patches/flutter2;
  flutter3Patches = getPatches ./patches/flutter3;
in
{
  inherit mkFlutter flutterDrv flutter2Patches flutter3Patches;
  stable = flutterDrv {
    pname = "flutter";
    version = "3.3.8";
    dartVersion = "2.18.4";
    flutterHash = rec {
      x86_64-linux = "sha256-QH+10F6a0XYEvBetiAi45Sfy7WTdVZ1i8VOO4JuSI24=";
      aarch64-linux = x86_64-linux;
      x86_64-darwin = "sha256-LZe5CTPaQtMy80PauXqYLOUxfpBP8Pzjyh6+EsfRlQE=";
      aarch64-darwin = "sha256-xJ1mpovY4t6hc3z1j3KCjhE/JCzk8o8miRe68w6mDqk=";
    };
    dartHash = {
      x86_64-linux = "sha256-lFw+KaxzhuAMnu6ypczINqywzpiD+8Kd+C/UHJDrO9Y=";
      aarch64-linux = "sha256-snlFTY4oJ4ALGLc210USbI2Z///cx1IVYUWm7Vo5z2I=";
      x86_64-darwin = "sha256-NQuRULldeEBZQuLXWqe0x/Ltn92Ci+o58fbAadNHD6U=";
      aarch64-darwin = "sha256-KmtJ65KFvYHZsXsnPbMDsnTy3pXnQXGiAx9CwYq8nck=";
    };
    patches = [
      ./patches/flutter3/disable-auto-update.patch
      ./patches/flutter3/git-dir.patch
      ./patches/flutter3/podhelper.patch
      ./patches/flutter3/move-cache.patch
      ];
  };

  v2 = flutterDrv {
    pname = "flutter";
    version = "2.10.5";
    dartVersion = "2.16.2";
    flutterHash = rec {
      x86_64-linux = "sha256-DTZwxlMUYk8NS1SaWUJolXjD+JnRW73Ps5CdRHDGnt0=";
      aarch64-linux = x86_64-linux;
    };
    dartHash = {
      x86_64-linux = "sha256-egrYd7B4XhkBiHPIFE2zopxKtQ58GqlogAKA/UeiXnI=";
      aarch64-linux = "sha256-vmerjXkUAUnI8FjK+62qLqgETmA+BLPEZXFxwYpI+KY=";
    };
    patches = flutter2Patches;
  };
}
