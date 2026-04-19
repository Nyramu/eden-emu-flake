{ ... }:
{
  flake.overlays.default = final: _: {
    eden = final.qt6Packages.callPackage ../package.nix { };
  };
}
