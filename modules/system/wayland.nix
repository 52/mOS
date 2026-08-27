{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) filterAttrs mkIf mkOption types;
  inherit (config) users;
  cfg = config.wayland;
in
{
  options.wayland = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable the "wayland" module.

        This enables the Wayland Display Protocol with a compositor
        managed by the "UWSM" (Universal Wayland Session Manager).
      '';
    };
  };

  config = mkIf cfg.enable {
    # Install system-wide dependencies.
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs)
        wl-clipboard
        woomer
        slurp
        grim
        mpv
        ;
    };

    # Enable "Hyprland".
    # See: https://github.com/hyprwm/Hyprland
    programs.hyprland = {
      enable = true;

      # Launch Hyprland with the UWSM (Universal Wayland Session Manager).
      # See: https://github.com/Vladimir-csp/uwsm
      withUWSM = true;
    };

    # Automatically start "UWSM" on login.
    programs.bash.loginShellInit = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        if uwsm check may-start; then
          exec uwsm start hyprland-uwsm.desktop
        fi
      fi
    '';

    # Configure "XDG Desktop Portal".
    # See: https://github.com/flatpak/xdg-desktop-portal
    xdg.portal = {
      enable = true;

      # Install the backend for "GTK".
      extraPortals = builtins.attrValues {
        inherit (pkgs)
          xdg-desktop-portal-gtk
          ;
      };

      # Configure the portal backends.
      # This prefers "Hyprland" and falls back to "GTK".
      config.common.default = [
        "hyprland"
        "gtk"
      ];
    };

    # Enable "Polkit".
    # See: https://wiki.archlinux.org/title/Polkit
    security.polkit.enable = true;

    # Manage the "video" group.
    users.groups.video = {
      members = builtins.attrNames (filterAttrs (_: user: user.isNormalUser or false) users.extraUsers);
    };
  };
}
