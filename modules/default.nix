{ self, ... }:
{
  flake.nixosModules.default =
    { config, lib, ... }:

    let
      cfg = config.programs.eden;
    in
    {
      options.programs.eden = {
        enable = lib.mkEnableOption "Eden emulator";
        package = lib.mkOption {
          type = lib.types.package;
          default = self.packages.x86_64-linux.default;
          description = "The Eden package to use.";
        };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ cfg.package ];
      };
    };

  flake.homeModules.default =
    { config, lib, ... }:

    let
      cfg = config.programs.eden;
    in
    {
      options.programs.eden = {
        enable = lib.mkEnableOption "Eden emulator";
        package = lib.mkOption {
          type = lib.types.package;
          default = self.packages.x86_64-linux.default;
          description = "The Eden package to use.";
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = [ cfg.package ];
      };
    };
}
