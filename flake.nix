{
  description = "My NixOS Configuration";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    nixpkgs-f2k.url = "github:fortuneteller2k/nixpkgs-f2k";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, neovim-nightly, nixpkgs-f2k }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; }; # Forgive me Mr. Stallman
      };

      overlays = [
        nixpkgs-f2k.overlay
        neovim-nightly.overlay
      ];
    in
    {
      homemanagerConfigurations = {
        ocean = home-manager.lib.homeManagerConfiguration {
          configuration = { pkgs, config, ... }:
            {
              home.stateVersion = "21.11";
              programs.home-manager.enable = true;
              nixpkgs.overlays = overlays;
              imports = [
                ./modules/shell
                ./modules/editors/neovim.nix
                ./modules/editors/emacs.nix
                ./modules/editors/vim.nix
                ./modules/dev/lua.nix
                ./modules/dev/node.nix
                ./modules/dev/rust.nix
                ./modules/dev/nix.nix
                ./modules/dev/python.nix
                ./modules/programs
                ./modules/programs/graphics.nix
                ./modules/desktop
                ./modules/desktop/windowManagers/awesome.nix
                ./modules/desktop/windowManagers/i3.nix
              ];
            };
          system = "x86_64-linux";
          homeDirectory = "/home/advait";
          username = "advait";
          stateVersion = "21.11";
        };
      };
      nixosConfigurations = {
        ocean = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs.overlays = overlays;
            }
            ./hosts/ocean/configuration.nix
          ];
        };
      };
    };
}
