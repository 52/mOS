{
  lib,
  inputs,
  ...
}:
rec {
  ## Convert a path to a relative path from the flake root.
  ## Appends the given path to the flake root directory.
  ##
  ## ```nix
  ## relativePath "system/audio.nix"
  ## ```
  ##
  #@ String -> Path
  relativePath = lib.path.append ../.;

  ## Read the contents of a file from a path relative to the flake root.
  ## Returns the file contents as a string.
  ##
  ## ```nix
  ## readFileRelative "bin/forge"
  ## ```
  ##
  #@ String -> String
  readFileRelative = path: builtins.readFile (relativePath path);

  ## Filter a list of filenames by extension.
  ## Returns only files matching the specified pattern.
  ##
  ## ```nix
  ## filterExt "rs" [ "main.rs" "rust-toolchain" ]
  ## ```
  ##
  #@ String -> [String] -> [String]
  filterExt = ext: files: builtins.filter (name: builtins.match ".*\\.${ext}" name != null) files;

  ## Collect paths to all files with a matching extension.
  ## Scans the directory and returns paths relative to the flake root.
  ##
  ## ```nix
  ## pathsIn "system" "nix"
  ## ```
  ##
  #@ String -> [Path]
  pathsIn =
    dir: ext:
    map (name: relativePath dir + "/${name}") (
      filterExt ext (builtins.attrNames (builtins.readDir (relativePath dir)))
    );

  ## Create an assertion that requires another module.
  ##
  ## ```nix
  ## assertions = [
  ##   (requireModule "steam" "wayland" config.wayland.enable)
  ## ];
  ## ```
  ##
  #@ String -> String -> Bool -> AttrSet
  requireModule = name: dependency: condition: {
    assertion = condition;
    message = ''
      Module "${name}" requires "${dependency}" which is not enabled.

      Resolve this issue by either:
        - Enabling the dependency:  ${dependency}.enable = true;
        - Disabling this module:    ${name}.enable = false;
    '';
  };

  ## Create a system user with a home-manager configuration.
  ##
  ## ```nix
  ## mkUser {
  ##   name = "max";
  ##   groups = [ "wheel" "docker" ];
  ##   packages = with pkgs; [ vim git ];
  ##   stateVersion = "24.11";
  ## }
  ## ```
  ##
  #@ AttrSet -> AttrSet
  mkUser =
    {
      ## Name of the system user account.
      ##
      #@ String
      name,

      ## Description of the system user account.
      ##
      #@ String
      description ? "",

      ## List of groups the user belongs to.
      ##
      #@ [String]
      extraGroups ? [ ],

      ## Whether this is a user account.
      ##
      #@ Bool
      isNormalUser ? true,

      ## List of packages to install for the user.
      ##
      #@ [Package]
      packages ? [ ],

      ## Set of secrets to provision for the user.
      ## Secrets are decrypted at activation using age encryption.
      ## See: https://github.com/ryantm/agenix
      ##
      #@ AttrSet
      secrets ? { },

      ## Home-manager modules configuration.
      ##
      #@ AttrSet
      home ? { },

      ## Home-manager state version.
      ## This should match the NixOS release version for compatibility.
      ## See: https://github.com/nix-community/home-manager/issues/5794
      ##
      #@ String
      stateVersion,
    }:
    {
      users.extraUsers.${name} = {
        inherit description isNormalUser extraGroups;
      };

      home-manager.users.${name} = lib.mkMerge [
        (lib.mkIf (secrets != { }) {
          imports = [ inputs.agenix.homeManagerModules.default ];

          age = {
            # Path to the private key used for decryption.
            identityPaths = [ "/home/${name}/.age-key" ];

            # Map secrets to their target locations and permissions.
            secrets = lib.mapAttrs (path: cfg: {
              inherit (cfg) mode;

              # The secrets encrypted origin.
              file = "${inputs.nix-secrets}/${path}.age";

              # The secrets decrypted target.
              path = "/home/${name}/${cfg.target}";
            }) secrets;
          };
        })

        (lib.mkIf (packages != [ ]) {
          home.packages = packages;
        })

        {
          home.stateVersion = stateVersion;
        }

        home
      ];
    };
}
