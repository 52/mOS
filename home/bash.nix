{ lib, config, ... }:
let
  inherit (lib) mkOption mkIf types;
in
{
  options = {
    bash = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config =
    let
      inherit (config) bash xdg;
    in
    mkIf bash.enable {
      programs = {
        bash = {
          enable = true;
          historyFile = "${xdg.dataHome}/bash/bash_history";
          profileExtra = ''
            if [ "$(tty)" = "/dev/tty1" ]; then
               if uwsm check may-start; then
                   exec uwsm start hyprland-uwsm.desktop
               fi
            fi
          '';
        };
      };
    };
}
