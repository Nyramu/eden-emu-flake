{ self, ... }:
{
  flake.homeModules.default = import ../homeModule.nix self;
}
