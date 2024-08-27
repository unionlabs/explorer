{
  description = "Build the Union ping-pub explorer";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];
    imports = [
      ./explorer.nix
    ];
    perSystem = { config, self', inputs', system, pkgs, lib, ... }: {

      _module.args = {
        inherit nixpkgs;

        pkgs = import nixpkgs {
          inherit system;
        };
      };

      devShells.default = pkgs.mkShell {
        name = "union-devShell";
        buildInputs = with pkgs; [
          emmet-language-server
          httpie
          jq
          marksman
          nil
          nixfmt
          nix-tree
          nodePackages.graphqurl
          nodePackages_latest.nodejs
          nodePackages_latest.svelte-language-server
          nodePackages_latest."@tailwindcss/language-server"
          nodePackages_latest.typescript-language-server
          nodePackages_latest.vscode-langservers-extracted
          yq
        ];

        PUPPETEER_SKIP_DOWNLOAD = 1; # avoid npm install downloading chromium
        NODE_OPTIONS = "--no-warnings"; # avoid useless warnings from nodejs
      };
    };
  };
  nixConfig = {
    extra-substituters = [ 
      "https://union.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [ 
      "union.cachix.org-1:TV9o8jexzNVbM1VNBOq9fu8NK+hL6ZhOyOh0quATy+M="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" 
    ];
    accept-flake-config = true;
  };
}
