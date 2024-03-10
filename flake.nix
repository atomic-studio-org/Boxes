# This flake was initially generated by fh, the CLI for FlakeHub (version 0.1.9)
{
  description = "Toolboxes for Atomic Studio";
  
  inputs = {
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*.tar.gz";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";
  };
  
  outputs = { self, flake-schemas, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in {
      schemas = flake-schemas.schemas;
      
      packages = forEachSupportedSystem ({ pkgs }: {
	# box-generate -> generates a new distrobox action using helm charts

	cosign-generate = pkgs.writeScriptBin "cosign-generate" ''
	  echo "DO NOT add any password, this will break your CI jobs!"
	  ${pkgs.lib.getExe pkgs.cosign} generate-keys-pair
	  cat cosign.key | ${pkgs.lib.getExe pkgs.gh} secret set SIGNING_SECRET --app actions --body 
	  rm cosign.key
	'';
      });
      
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nixpkgs-fmt
	    cosign
	    podman
          ];
        };
      });
    };
}
