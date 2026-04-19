self:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.eden;
in
{
  options.programs.eden = {
    enable = lib.mkEnableOption "Eden emulator";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.qt6Packages.callPackage (self + "/package.nix") { };
      defaultText = lib.literalExpression "pkgs.qt6Packages.callPackage (self + \"/package.nix\") { }";
      description = "The Eden package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
