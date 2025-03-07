{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption mkIf types;
in
{
  options = {
    system = {
      bluetooth = {
        enable = mkOption {
          type = types.bool;
          default = true;
        };
      };
    };
  };
  config =
    let
      inherit (config) system;
      inherit (system) bluetooth;
    in
    mkIf bluetooth.enable {
      hardware = {
        bluetooth = {
          enable = true;
          powerOnBoot = true;
        };
      };
    };
}
