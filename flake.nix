{
  description = "Eden Emulator";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
  };

  outputs =
    inputs@{ flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (import-tree ./modules);

  nixConfig = {
    extra-substituters = [ "https://eden-emu-flake.cachix.org" ];
    extra-trusted-public-keys = [
      "eden-emu-flake.cachix.org-1:qMKfHpBsRhMpxrc4FawVy+IeYAvFhhv94qiB69Bl0RU="
    ];
  };
}
