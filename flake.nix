{
  description = "A very basic geenie";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    odin-custom = pkgs.callPackage ./nix/odin-pkg.nix {};
    system = "x86_64-linux";

    pkgs = import nixpkgs { inherit system; };
  in {
    devShell.${system} = with pkgs; mkShell {
      nativeBuildInputs = [
        gnumake
        odin-custom
        ols
      ];

      buildInputs = [
        libffi
        libGL
        glfw

        libxkbcommon
        fontconfig
        wayland
        xwayland

        xorg.libX11
        xorg.libXcursor
        xorg.libXi
        xorg.libXmu
        xorg.libXrandr
      ];
    };
  };
}
