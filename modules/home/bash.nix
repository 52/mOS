{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkMerge optionalAttrs;
  inherit (config) git tmux vim;
in
{
  programs = {
    # Enable "bash".
    # See: https://www.gnu.org/software/bash
    bash = {
      enable = true;

      # Limit the history size to n-lines.
      historySize = 500000;
      # Limit the on-disk history file to n-lines.
      historyFileSize = 100000;
      # Relocate the ".bash_history" file from $HOME.
      historyFile = "$XDG_DATA_HOME/bash/bash_history";

      shellOptions = [
        # Enable recursive pattern matching with "**".
        "globstar 2> /dev/null"
        # Enable case-insensitive filename matching.
        "nocaseglob"
        # Append new lines to the history file.
        "histappend"
        # Check the window size after each command.
        "checkwinsize"
        # Save multi-line commands as a single history entry.
        "cmdhist"
        # Automatically prepend "cd" to directory names.
        "autocd 2> /dev/null"
        # Automatically correct spelling errors in "cd".
        "cdspell 2> /dev/null"
        # Automatically correct spelling errors in completion.
        "dirspell 2> /dev/null"
      ];

      shellAliases = mkMerge [
        (optionalAttrs vim.enable {
          "v" = "vim";
          "vi" = "vim";
        })

        (optionalAttrs git.enable {
          "g" = "git";
          "ga" = "git add";
          "gb" = "git branch";
          "gc" = "git commit";
          "gd" = "git diff";
          "gl" = "git log";
          "gp" = "git push";
          "gs" = "git status";
        })

        (optionalAttrs tmux.enable {
          "t" = "tmux";
          "ta" = "tmux attach";
          "td" = "tmux detach";
          "tk" = "tmux kill-session -t";
          "tl" = "tmux ls";
        })
      ];

      initExtra = ''
        # Enable case-insensitive completion.
        bind "set completion-ignore-case on"

        # Treat hyphens and underscores as equivalent.
        bind "set completion-map-case on"

        # Display all matches immediately.
        bind "set show-all-if-ambiguous on"

        # Append slashes to symlinked directories.
        bind "set mark-symlinked-directories on"

        # Move the cursor to EOL when cycling through history.
        bind "set history-preserve-point off"

        # Enable cycling through tab completion options.
        bind "tab: menu-complete"
        bind '"\e[Z": menu-complete-backward'

        # Enable incremental history search with arrow keys.
        bind '"\e[A": history-search-backward'
        bind '"\e[B": history-search-forward'
        bind '"\e[C": forward-char'
        bind '"\e[D": backward-char'

        # Disable terminal flow control.
        # See: https://unix.stackexchange.com/a/12146
        stty -ixon
        bind -r '\C-s'

        # Load the "__git_ps1" command.
        . $HOME/.nix-profile/share/git/contrib/completion/git-prompt.sh

        # Load the "__nix_ps1" command.
        __nix_ps1() {
          if [ -n "$NIX_FLAKE_NAME" ]; then
            printf " [%s]" "$NIX_FLAKE_NAME"
          elif [ -n "$IN_NIX_SHELL" ]; then
            echo " [*]"
          fi
        }

        # Load the "__ssh_ps1" command.
        __ssh_ps1() {
          if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
            printf " [ssh:%s]" "$(hostname -s)"
          fi
        }

        # Remove the bold ("01") SGR attribute from LS_COLORS.
        # See: https://man7.org/linux/man-pages/man5/dir_colors.5.html
        LS_COLORS=''${LS_COLORS//=01/=00}
        LS_COLORS=''${LS_COLORS//;01/;00}

        # Remove the bold ("01") SGR attribute from EZA_COLORS.
        # See: https://man.archlinux.org/man/extra/eza/eza_colors.5.en
        EZA_METAS="uu=33:gu=33:lc=31:df=32:nk=32:uk=32:xx=90:Gd=33"
        EZA_FILES="di=34:bd=33:cd=33:so=31:ex=32:mp=34;4"
        EZA_TYPES="vi=35:lo=36:cr=32:bu=33;4:sc=33"
        EZA_PERMS="ur=33:uw=31:ux=32;4:ue=32"

        # Export the customized color definitions.
        export EZA_COLORS="$EZA_FILES:$EZA_PERMS:$EZA_METAS:$EZA_TYPES"
        export LS_COLORS

        # Load the custom prompt.
        PS1="\n\[\e[32m\]\w\[\e[35m\]\$(__ssh_ps1)\[\e[36m\]\$(__nix_ps1)\$(__git_ps1 \"\[\e[31m\] [%s]\")\[\e[0m\] "
      '';
    };

    # Enable "direnv".
    # See: https://direnv.net
    direnv = {
      enable = true;

      # Enable "nix-direnv".
      # See: https://github.com/nix-community/nix-direnv
      nix-direnv.enable = true;
    };

    # Enable "eza".
    # See: https://github.com/eza-community/eza
    eza = {
      enable = true;
      enableBashIntegration = true;

      extraOptions = [
        "--group-directories-first"
        "--git"
        "-lF"
      ];
    };
  };
}
