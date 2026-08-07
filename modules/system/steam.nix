{
  lib,
  config,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.steam;
in
{
  imports = builtins.attrValues {
    inherit (inputs.nix-gaming.nixosModules)
      platformOptimizations
      pipewireLowLatency
      ;
  };

  options.steam = {
    enable = mkOption {
      type = types.bool;
      default = config.wayland.enable;
      description = ''
        Whether to enable the "steam" module.

        This enables the Steam platform with optimizations
        from the "nix-gaming" modules.
      '';
    };

    members = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        List of users to add to the "gamemode" group.

        These users will be able to use GameMode for
        performance optimizations while gaming.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Enforce the module dependencies.
    assertions = [
      (lib.requireModule "steam" "wayland" config.wayland.enable)
    ];

    # Enable "Steam".
    # See: https://store.steampowered.com
    programs.steam = {
      enable = true;

      # Enable a variety of platform optimizations.
      platformOptimizations.enable = true;
    };

    # Enable "GameMode".
    # See: https://wiki.archlinux.org/title/GameMode
    programs.gamemode.enable = true;

    # Enable low-latency audio compatibility.
    services.pipewire.lowLatency.enable = true;

    # Manage the "gamemode" group.
    users.groups.gamemode = {
      inherit (cfg) members;
    };
  };
}
