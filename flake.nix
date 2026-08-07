{
  description = "A modular, multi-host nixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixOS/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-secrets = {
      url = "github:52/nix-secrets";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      systems = [
        "x86_64-linux"
      ];

      # Generate an attribute set for each system.
      forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});

      # Generate "nixpkgs" for each system.
      pkgsFor = lib.genAttrs systems (
        system:
        import nixpkgs {
          inherit system;
        }
      );

      # Custom library, see: "lib" folder.
      lib = nixpkgs.lib.extend (
        _: _:
        import ./lib {
          inherit (nixpkgs) lib;
          inherit inputs;
        }
      );

      # Custom packages, see: "pkgs" folder.
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });

      # Custom overlays, see: "overlays" folder.
      overlays = import ./overlays { inherit inputs; };

      specialArgs = {
        inherit lib inputs outputs;
      };
    in
    {
      inherit overlays packages;

      # Formatter used by "nix fmt".
      # See: https://nix-community.github.io/nixpkgs-fmt/
      formatter = forEachSystem (pkgs: pkgs.nixfmt-rfc-style);

      # Shell used by "nix develop".
      # See: https://nix.dev/manual/nix/2.18/command-ref/new-cli/nix3-develop
      devShells = forEachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            amber-lang
          ];
        };
      });

      nixosConfigurations = {
        m001-x86 = lib.nixosSystem {
          inherit specialArgs;
          modules = map lib.relativePath [
            "modules/host/m001-x86"
          ];
        };
      };
    };
}
