{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    devenv.url = "github:cachix/devenv";
    nix-filter.url = "github:numtide/nix-filter";
  };

  outputs = { self, nixpkgs, devenv, ... } @ inputs:
    let
      systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = f: builtins.listToAttrs (map (name: { inherit name; value = f name; }) systems);
    in
    {
      devShells = forAllSystems
        (system:
          let
            pkgs = import nixpkgs {
              inherit system;
            };
            hpkgs = pkgs.haskellPackages;
            Top = with pkgs.haskell.lib;
              with hpkgs;
              with inputs;
              callCabal2nix "Top" (nix-filter.lib.filter {
                root = self;
                exclude = [ "package.yaml" ];
              }) { };
          in
          {
            default = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                {
                  env.name = "bug.01";
                  env.GREET = "bug.01";
                  packages = [ Top ];
                  scripts.hello.exec = "echo hello from $GREET";
                  enterShell = ''
                    hello
                  '';
                }
              ];
            };
          });
    };
}
