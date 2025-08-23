{ pkgs-stable, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      texlive = pkgs-stable.texlive;
      sage = prev.sage.override { requireSageTests = false; };
    })
  ];
}
