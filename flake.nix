{
  description = "mediacp — media-library organiser using Claude";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        {
          default = pkgs.writeShellApplication {
            name = "mediacp";
            runtimeInputs = [ pkgs.python3 pkgs.claude-code ];
            text = ''
              exec python3 ${./mediacp} "$@"
            '';
          };
        });

      homeManagerModules.default = { config, lib, pkgs, ... }:
        let
          cfg = config.programs.mediacp;
          pkg = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in
        {
          options.programs.mediacp.enable =
            lib.mkEnableOption "mediacp media organiser";

          config = lib.mkIf cfg.enable {
            home.packages = [ pkg ];

            home.file.".claude/skills/mediacp".source =
              "${self}/.claude/skills/mediacp";
          };
        };
    };
}
