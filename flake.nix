{
  description = "Flutter environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      android_sdk.accept_license = true;
    };
    buildToolsVersion = "34.0.0";
    cmakeVersion = "3.22.1";

    androidEnv = pkgs.androidenv.override {licenseAccepted = true;};
    androidComposition = androidEnv.composeAndroidPackages {
      cmdLineToolsVersion = "8.0";
      platformToolsVersion = "36.0.1";
      buildToolsVersions = [buildToolsVersion];
      platformVersions = ["31" "32" "33" "34" "35"];
      includeNDK = true;
      ndkVersion = "27.0.12077973";
      cmakeVersions = [cmakeVersion];
      includeEmulator = false;
      useGoogleAPIs = false;
      extraLicenses = [
        "android-sdk-arm-dbt-license"
        "android-sdk-license"
      ];
    };
    androidSdk = androidComposition.androidsdk;
    flutter = pkgs.flutter332;
  in {
    devShells.${system}.default = pkgs.mkShell rec {
      ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
      ANDROID_HOME = ANDROID_SDK_ROOT;
      ANDROID_NDK_ROOT = "${ANDROID_SDK_ROOT}/ndk-bundle";
      JAVA_HOME = pkgs.jdk17.home;
      FLUTTER_ROOT = flutter;
      DART_ROOT = "${flutter}/bin/cache/dart-sdk";
      GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_SDK_ROOT}/build-tools/${buildToolsVersion}/aapt2";
      QT_QPA_PLATFORM = "wayland;xcb"; # emulator related: try using wayland, otherwise fall back to X.
      # NB: due to the emulator's bundled qt version, it currently does not start with QT_QPA_PLATFORM="wayland".
      # Maybe one day this will be supported.
      buildInputs = with pkgs; [
        androidSdk
        flutter
        rustup
        qemu_kvm
        gradle
        jdk17
        android-studio
      ];
      # emulator related: vulkan-loader and libGL shared libs are necessary for hardware decoding
      LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath [pkgs.vulkan-loader pkgs.libGL]}";
      # Globally installed packages, which are installed through `dart pub global activate package_name`,
      # are located in the `$PUB_CACHE/bin` directory.
      shellHook = ''
        if [ -z "$PUB_CACHE" ]; then
          export PATH="$PATH:$HOME/.pub-cache/bin"
        else
          export PATH="$PATH:$PUB_CACHE/bin"
        fi

        export PATH="$(echo "$ANDROID_SDK_ROOT/cmake/${cmakeVersion}".*/bin):$PATH"
      '';
    };
  };
}
