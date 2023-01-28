{ pkgs, inputs, ... }:
let
  hpkgs = pkgs.haskellPackages;
  Top = with pkgs.haskell.lib;
    with hpkgs;
    with inputs;
    callCabal2nix "Top" (nix-filter.lib.filter {
      root = self;
      exclude = [ "package.yaml" ];
    }) { };
in {
  env.name = "bug.01";
  env.GREET = "bug.01";
  packages = [ Top ];
  scripts.hello.exec = "echo hello from $GREET";
  enterShell = ''
    hello
  '';
}
