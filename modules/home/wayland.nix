{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (osConfig) keyboard wayland;
  inherit (config) env theme;
in
mkIf wayland.enable {
  # Enable "Hyprland".
  # See: https://github.com/hyprwm/hyprland
  wayland.windowManager.hyprland = {
    enable = true;

    # Use the system-wide Hyprland package (managed by UWSM).
    # See: https://wiki.hyprland.org/Useful-Utilities/Systemd-start
    package = null;

    # Disable the systemd integration (managed by UWSM).
    # See: https://github.com/Vladimir-csp/uwsm
    systemd.enable = false;

    # Install Hyprland plugins.
    # See: https://wiki.hyprland.org/Plugins/Using-Plugins
    plugins = builtins.attrValues {
      inherit (pkgs.hyprlandPlugins)
        hyprbars
        hyprexpo
        hy3
        ;
    };

    settings = {
      "$mod" = "SUPER";

      general = {
        # Set the window layout.
        layout = "hy3";
        # Set the gaps between windows.
        gaps_in = 4;
        # Set the gaps between windows and screen edges.
        gaps_out = 4;
        # Disable the native window borders.
        border_size = 0;
      };

      input = {
        # Set the keyboard variant.
        kb_variant = keyboard.variant;
        # Set the keyboard layout.
        kb_layout = keyboard.layout;
        # Set the repetition delay.
        repeat_delay = "200";
        # Set the repetition rate.
        repeat_rate = "90";
        # Set the mouse focus mode.
        follow_mouse = 2;
        # Don't focus windows with mouse.
        mouse_refocus = false;
      };

      cursor = {
        # Disable the cursor warping on focus change.
        no_warps = true;
        # Hide the cursor after a keypress.
        hide_on_key_press = true;
        # Set the cursor inactivity timeout (seconds).
        inactive_timeout = 3;
      };

      misc = {
        # Disable middle-click paste.
        middle_click_paste = false;
        # Disable the default Hyprland logo.
        disable_hyprland_logo = true;
        # Disable the default Hyprland splash.
        disable_splash_rendering = true;
      };

      animations = {
        # Define a snappy bezier curve.
        bezier = [ "snappy, 0.2, 1.0, 0.3, 1.0" ];

        animation = [
          # Set the window open animation.
          "windowsIn, 1, 3, snappy, popin 80%"
          # Set the window close animation.
          "windowsOut, 1, 3, snappy, popin 80%"
          # Set the window move animation.
          "windowsMove, 1, 3, snappy"
          # Set the workspace switch animation.
          "workspaces, 1, 3, snappy, slide"
          # Set the fade animation.
          "fade, 1, 3, snappy"
        ];
      };

      decoration = {
        # Set the window rounding.
        rounding = 6;
        # Enable the inactive window dimming.
        dim_inactive = true;
        # Set the inactive window dimming strength.
        dim_strength = 0.2;
      };

      windowrulev2 = [
        # Set the title bar color for focused windows.
        "plugin:hyprbars:bar_color rgb(${theme.colors.active.background}), focus:1"
        # Set the title text color for focused windows.
        "plugin:hyprbars:title_color rgb(${theme.colors.active.foreground}), focus:1"
        # Set the title bar color for unfocused windows.
        "plugin:hyprbars:bar_color rgb(${theme.colors.inactive.background}), focus:0"
        # Set the title text color for unfocused windows.
        "plugin:hyprbars:title_color rgb(${theme.colors.inactive.foreground}), focus:0"
      ];

      plugin = {
        # Configure "Hyprbars".
        # See: https://github.com/hyprwm/hyprland-plugins/tree/main/hyprbars
        hyprbars = {
          # Set the bar height.
          bar_height = 32;
          # Set the bar padding.
          bar_padding = 10;
          # Set the bar button padding.
          bar_button_padding = 12;
          # Set the bar text font.
          bar_text_font = "pixel";
          # Include the bar as part of the window.
          bar_part_of_window = true;
          # Draw the bar above the window border.
          bar_precedence_over_border = true;
        };
      };

      bind = [
        # <MOD> + Q to kill window.
        "$mod, Q, killactive"
        # <MOD> + <Shift> + Q to exit.
        "$mod SHIFT, Q, exit"

        # <MOD> + N to toggle floating.
        "$mod, N, togglefloating"
        # <MOD> + M to toggle fullscreen.
        "$mod, M, fullscreen"

        # <MOD> + T to open $TERMINAL.
        "$mod, T, exec, uwsm app -- ${env.TERMINAL or "foot"}"
        # <MOD> + F to open $BROWSER.
        "$mod, F, exec, uwsm app -- ${env.BROWSER or "firefox"}"

        # <MOD> + W to toggle workspace overview.
        "$mod, W, hyprexpo:expo, toggle"

        # <MOD> + <Space> to toggle application launcher.
        "$mod, SPACE, exec, uwsm app -- vicinae toggle"

        # <MOD> + 1 to switch workspace (1).
        "$mod, 1, workspace, 1"
        # <MOD> + 2 to switch workspace (2).
        "$mod, 2, workspace, 2"
        # <MOD> + 3 to switch workspace (3).
        "$mod, 3, workspace, 3"
        # <MOD> + 4 to switch workspace (4).
        "$mod, 4, workspace, 4"
        # <MOD> + 5 to switch workspace (5).
        "$mod, 5, workspace, 5"
        # <MOD> + 6 to switch workspace (6).
        "$mod, 6, workspace, 6"
        # <MOD> + 7 to switch workspace (7).
        "$mod, 7, workspace, 7"
        # <MOD> + 8 to switch workspace (8).
        "$mod, 8, workspace, 8"
        # <MOD> + 9 to switch workspace (9).
        "$mod, 9, workspace, 9"

        # <MOD> + <Shift> + 1 to move focused window to workspace (1).
        "$mod SHIFT, 1, movetoworkspace, 1"
        # <MOD> + <Shift> + 2 to move focused window to workspace (2).
        "$mod SHIFT, 2, movetoworkspace, 2"
        # <MOD> + <Shift> + 3 to move focused window to workspace (3).
        "$mod SHIFT, 3, movetoworkspace, 3"
        # <MOD> + <Shift> + 4 to move focused window to workspace (4).
        "$mod SHIFT, 4, movetoworkspace, 4"
        # <MOD> + <Shift> + 5 to move focused window to workspace (5).
        "$mod SHIFT, 5, movetoworkspace, 5"
        # <MOD> + <Shift> + 6 to move focused window to workspace (6).
        "$mod SHIFT, 6, movetoworkspace, 6"
        # <MOD> + <Shift> + 7 to move focused window to workspace (7).
        "$mod SHIFT, 7, movetoworkspace, 7"
        # <MOD> + <Shift> + 8 to move focused window to workspace (8).
        "$mod SHIFT, 8, movetoworkspace, 8"
        # <MOD> + <Shift> + 9 to move focused window to workspace (9).
        "$mod SHIFT, 9, movetoworkspace, 9"

        # <MOD> + <Shift> + L to move focused window (R).
        "$mod SHIFT, L, movewindow, r"
        # <MOD> + <Shift> + H to move focused window (L).
        "$mod SHIFT, H, movewindow, l"

        # <MOD> + <Tab> to cycle focus (NEXT).
        "$mod, Tab, cyclenext"
        # <MOD> + <Shift> + <Tab> to cycle focus (PREV).
        "$mod SHIFT, Tab, cyclenext, prev"

        # <Print> to capture the entire screen.
        ", Print, exec, grim | wl-copy"
        # <MOD> + <Print> to capture a selected area.
        "$mod, Print, exec, grim -g \"$(slurp)\" | wl-copy"
        # <MOD> + <Shift> + <Print> to zoom into an area.
        "$mod SHIFT, Print, exec, woomer"
      ];

      binde = [
        # <XF86AudioRaiseVolume> to increase volume.
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        # <XF86AudioLowerVolume> to decrease volume.
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      bindl = [
        # <XF86AudioMute> to mute volume.
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];

      bindm = [
        # <MOD> + <LMB> to move window.
        "$mod, mouse:272, movewindow"
        # <MOD> + <RMB> to resize window.
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  # Enable "Hyprpaper".
  # See: https://github.com/hyprwm/hyprpaper
  services.hyprpaper = {
    enable = true;

    settings = {
      # Preload the wallpaper.
      preload = [ "${theme.wallpaper}" ];
      # Display the wallpaper for all outputs.
      wallpaper = [ ", ${theme.wallpaper}" ];
    };
  };

  # Enable "Vicinae".
  # See: https://github.com/vicinaehq/vicinae
  programs.vicinae = {
    enable = true;

    # Autostart the server on boot.
    systemd.enable = true;
  };

  # Configure "GTK".
  # See: https://gtk.org
  gtk = {
    enable = true;

    # Set the GTK theme.
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    # Set the icon theme.
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };

    # Prefer dark colorscheme for GTK3.
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    # Prefer dark colorscheme for GTK4.
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Set the cursor theme.
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;

    # Set the cursor for GTK applications.
    gtk.enable = true;

    # Generate a Hyprcursor theme.
    hyprcursor.enable = true;
  };

  # Set the interface preferences for GNOME.
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "Adwaita-dark";
  };
}
