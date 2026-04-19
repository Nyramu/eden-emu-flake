{ ... }:
{
  perSystem = { pkgs, ... }: {
    packages = {
      eden = pkgs.qt6Packages.callPackage ../package.nix { };
      default = pkgs.qt6Packages.callPackage ../package.nix { };
    };
  };
}
