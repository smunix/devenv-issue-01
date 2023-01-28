# devenv-issue-01

This repository uses [`nix-filter`](https://github.com/numtide/nix-filter) to filter out certain files during the build process. 

`devenv` does not let you filter files using 'nix-filter'

## Problem description

Creating a Haskell package with `callCabal2nix` while excluding the `package.yaml` shouldn't build the `Top` package below:

``` nix
  Top = with pkgs.haskell.lib;
    with hpkgs;
    with inputs;
    callCabal2nix "Top" (nix-filter.lib.filter {
      root = self;
      exclude = [ "package.yaml" ];
    }) { };
```

`nix-filter` is imported in `devenv.yaml`:

``` yaml
inputs:
  nix-filter:
    url: github:numtide/nix-filter
```

Run `devenv shell Top`, and it prints:

``` shell
> "devenv sits at the Top"
```

Here's the full log:

``` shell
Last login: Sat Jan 28 03:52:12 on ttys002
smunix bug.01 % devenv shell Top
Building shell ...
warning: applying 'toString' to path '/Users/smunix/programming/devenvs/bug.01/package.yaml' and then accessing it is deprecated, at «github:numtide/nix-filter/1a3b735e13e90a8d2fd5629f2f8363bd7ffbbec7»/default.nix:164:7
warning: applying 'toString' to path '/Users/smunix/programming/devenvs/bug.01/' and then accessing it is deprecated, at «github:numtide/nix-filter/1a3b735e13e90a8d2fd5629f2f8363bd7ffbbec7»/default.nix:165:8
hello from bug.01
"devenv sits at the Top"
smunix bug.01 % 
```

## What was expected

Since we are building a Haskell package, the invocation to `callCabal2nix` finds and uses the `package.yaml` file to make a derivation. Given that we explicitly stated that we wanted that file exclude, `exclude = [ "package.yaml" ]`, the build should have failed.

Using `devenv` with `flake` (defined in the same repository) produces the expected result:

``` shell
> cabal2nix: user error (*** Found neither a .cabal file nor package.yaml. Exiting.)
```

Here is the full log:

``` shell
smunix bug.01 % nix develop -c Top
warning: Git tree '/Users/smunix/programming/devenvs/bug.01' is dirty
warning: creating lock file '/Users/smunix/programming/devenvs/bug.01/flake.lock'
warning: Git tree '/Users/smunix/programming/devenvs/bug.01' is dirty
error: builder for '/nix/store/dh6w3j6mkl98kx2970qravsv26jxm154-cabal2nix-Top.drv' failed with exit code 1;
       last 1 log lines:
       > cabal2nix: user error (*** Found neither a .cabal file nor package.yaml. Exiting.)
       For full logs, run 'nix log /nix/store/dh6w3j6mkl98kx2970qravsv26jxm154-cabal2nix-Top.drv'.
(use '--show-trace' to show detailed location information)

```


